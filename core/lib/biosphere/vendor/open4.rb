# Because of this bug http://bugs.ruby-lang.org/issues/show/1287
# We need this library https://github.com/ahoward/open4
# The license is the same as Ruby's

# Ruby is copyrighted free software by Yukihiro Matsumoto <matz@netlab.jp>.
# You can redistribute it and/or modify it under either the terms of the
# 2-clause BSDL (see the file BSDL), or the conditions below:
#
#   1. You may make and give away verbatim copies of the source form of the
#      software without restriction, provided that you duplicate all of the
#      original copyright notices and associated disclaimers.
#
#   2. You may modify your copy of the software in any way, provided that
#      you do at least ONE of the following:
#
#        a) place your modifications in the Public Domain or otherwise
#           make them Freely Available, such as by posting said
#           modifications to Usenet or an equivalent medium, or by allowing
#           the author to include your modifications in the software.
#
#        b) use the modified software only within your corporation or
#           organization.
#
#        c) give non-standard binaries non-standard names, with
#           instructions on where to get the original software distribution.
#
#        d) make other distribution arrangements with the author.
#
#   3. You may distribute the software in object code or binary form,
#      provided that you do at least ONE of the following:
#
#        a) distribute the binaries and library files of the software,
#           together with instructions (in the manual page or equivalent)
#           on where to get the original distribution.
#
#        b) accompany the distribution with the machine-readable source of
#           the software.
#
#        c) give non-standard binaries non-standard names, with
#           instructions on where to get the original software distribution.
#
#        d) make other distribution arrangements with the author.
#
#   4. You may modify and include the part of the software into any other
#      software (possibly commercial).  But some files in the distribution
#      are not written by the author, so that they are not under these terms.
#
#      For the list of those files and their copying conditions, see the
#      file LEGAL.
#
#   5. The scripts and library files supplied as input to or produced as
#      output from the software do not automatically fall under the
#      copyright of the software, but belong to whomever generated them,
#      and may be sold commercially, and may be aggregated with this
#      software.
#
#   6. THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
#      IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
#      WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#      PURPOSE.

require 'fcntl'
require 'timeout'
require 'thread'

module Open4
  VERSION = '1.3.0'
  def self.version() VERSION end

  class Error < ::StandardError; end

  def pfork4(fun, &b)
    Open4.do_popen(b, :block) do |ps_read, _|
      ps_read.close
      begin
        fun.call
      rescue SystemExit => e
        # Make it seem to the caller that calling Kernel#exit in +fun+ kills
        # the child process normally. Kernel#exit! bypasses this rescue
        # block.
        exit! e.status
      else
        exit! 0
      end
    end
  end
  module_function :pfork4

  def popen4(*cmd, &b)
    Open4.do_popen(b, :init) do |ps_read, ps_write|
      ps_read.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
      ps_write.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
      exec(*cmd)
      raise 'forty-two'   # Is this really needed?
    end
  end
  alias open4 popen4
  module_function :popen4
  module_function :open4

  def popen4ext(closefds=false, *cmd, &b)
    Open4.do_popen(b, :init, closefds) do |ps_read, ps_write|
      ps_read.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
      ps_write.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)
      exec(*cmd)
      raise 'forty-two'   # Is this really needed?
    end
  end
  module_function :popen4ext

  def self.do_popen(b = nil, exception_propagation_at = nil, closefds=false, &cmd)
    pw, pr, pe, ps = IO.pipe, IO.pipe, IO.pipe, IO.pipe

    verbose = $VERBOSE
    begin
      $VERBOSE = nil

      cid = fork {
        if closefds
          exlist = [0, 1, 2] | [pw,pr,pe,ps].map{|p| [p.first.fileno, p.last.fileno] }.flatten
          ObjectSpace.each_object(IO){|io|
            io.close if (not io.closed?) and (not exlist.include? io.fileno) rescue nil
          }
        end

        pw.last.close
        STDIN.reopen pw.first
        pw.first.close

        pr.first.close
        STDOUT.reopen pr.last
        pr.last.close

        pe.first.close
        STDERR.reopen pe.last
        pe.last.close

        STDOUT.sync = STDERR.sync = true

        begin
          cmd.call(ps)
        rescue Exception => e
          Marshal.dump(e, ps.last)
          ps.last.flush
        ensure
          ps.last.close unless ps.last.closed?
        end

        exit!
      }
    ensure
      $VERBOSE = verbose
    end

    [ pw.first, pr.last, pe.last, ps.last ].each { |fd| fd.close }

    Open4.propagate_exception cid, ps.first if exception_propagation_at == :init

    pw.last.sync = true

    pi = [ pw.last, pr.first, pe.first ]

    begin
      return [cid, *pi] unless b

      begin
        b.call(cid, *pi)
      ensure
        pi.each { |fd| fd.close unless fd.closed? }
      end

      Open4.propagate_exception cid, ps.first if exception_propagation_at == :block

      Process.waitpid2(cid).last
    ensure
      ps.first.close unless ps.first.closed?
    end
  end

  def self.propagate_exception(cid, ps_read)
    e = Marshal.load ps_read
    raise Exception === e ? e : "unknown failure!"
  rescue EOFError
    # Child process did not raise exception.
  rescue
    # Child process raised exception; wait it in order to avoid a zombie.
    Process.waitpid2 cid
    raise
  ensure
    ps_read.close
  end

  class SpawnError < Error
    attr 'cmd'
    attr 'status'
    attr 'signals'
    def exitstatus
      @status.exitstatus
    end
    def initialize cmd, status
      @cmd, @status = cmd, status
      @signals = {}
      if status.signaled?
        @signals['termsig'] = status.termsig
        @signals['stopsig'] = status.stopsig
      end
      sigs = @signals.map{|k,v| "#{ k }:#{ v.inspect }"}.join(' ')
      super "cmd <#{ cmd }> failed with status <#{ exitstatus.inspect }> signals <#{ sigs }>"
    end
  end

  class ThreadEnsemble
    attr 'threads'

    def initialize cid
      @cid, @threads, @argv, @done, @running = cid, [], [], Queue.new, false
      @killed = false
    end

    def add_thread *a, &b
      @running ? raise : (@argv << [a, b])
    end

#
# take down process more nicely
#
    def killall
      c = Thread.critical
      return nil if @killed
      Thread.critical = true
      (@threads - [Thread.current]).each{|t| t.kill rescue nil}
      @killed = true
    ensure
      Thread.critical = c
    end

    def run
      @running = true

      begin
        @argv.each do |a, b|
          @threads << Thread.new(*a) do |*a|
            begin
              b[*a]
            ensure
              killall rescue nil if $!
              @done.push Thread.current
            end
          end
        end
      rescue
        killall
        raise
      ensure
        all_done
      end

      @threads.map{|t| t.value}
    end

    def all_done
      @threads.size.times{ @done.pop }
    end
  end

  def to timeout = nil
    Timeout.timeout(timeout){ yield }
  end
  module_function :to

  def new_thread *a, &b
    cur = Thread.current
    Thread.new(*a) do |*a|
      begin
        b[*a]
      rescue Exception => e
        cur.raise e
      end
    end
  end
  module_function :new_thread

  def getopts opts = {}
    lambda do |*args|
      keys, default, ignored = args
      catch(:opt) do
        [keys].flatten.each do |key|
          [key, key.to_s, key.to_s.intern].each do |key|
            throw :opt, opts[key] if opts.has_key?(key)
          end
        end
        default
      end
    end
  end
  module_function :getopts

  def relay src, dst = nil, t = nil
    send_dst =
      if dst.respond_to?(:call)
        lambda{|buf| dst.call(buf)}
      elsif dst.respond_to?(:<<)
        lambda{|buf| dst << buf }
      else
        lambda{|buf| buf }
      end

    unless src.nil?
      if src.respond_to? :gets
        while buf = to(t){ src.gets }
          send_dst[buf]
        end

      elsif src.respond_to? :each
        q = Queue.new
        th = nil

        timer_set = lambda do |t|
          th = new_thread{ to(t){ q.pop } }
        end

        timer_cancel = lambda do |t|
          th.kill if th rescue nil
        end

        timer_set[t]
        begin
          src.each do |buf|
            timer_cancel[t]
            send_dst[buf]
            timer_set[t]
          end
        ensure
          timer_cancel[t]
        end

      elsif src.respond_to? :read
        buf = to(t){ src.read }
        send_dst[buf]

      else
        buf = to(t){ src.to_s }
        send_dst[buf]
      end
    end
  end
  module_function :relay

  def spawn arg, *argv
    argv.unshift(arg)
    opts = ((argv.size > 1 and Hash === argv.last) ? argv.pop : {})
    argv.flatten!
    cmd = argv.join(' ')


    getopt = getopts opts

    ignore_exit_failure = getopt[ 'ignore_exit_failure', getopt['quiet', false] ]
    ignore_exec_failure = getopt[ 'ignore_exec_failure', !getopt['raise', true] ]
    exitstatus = getopt[ %w( exitstatus exit_status status ) ]
    stdin = getopt[ %w( stdin in i 0 ) << 0 ]
    stdout = getopt[ %w( stdout out o 1 ) << 1 ]
    stderr = getopt[ %w( stderr err e 2 ) << 2 ]
    pid = getopt[ 'pid' ]
    timeout = getopt[ %w( timeout spawn_timeout ) ]
    stdin_timeout = getopt[ %w( stdin_timeout ) ]
    stdout_timeout = getopt[ %w( stdout_timeout io_timeout ) ]
    stderr_timeout = getopt[ %w( stderr_timeout ) ]
    status = getopt[ %w( status ) ]
    cwd = getopt[ %w( cwd dir ) ]
    closefds = getopt[ %w( close_fds ) ]

    exitstatus =
      case exitstatus
        when TrueClass, FalseClass
          ignore_exit_failure = true if exitstatus
          [0]
        else
          [*(exitstatus || 0)].map{|i| Integer i}
      end

    stdin ||= '' if stdin_timeout
    stdout ||= '' if stdout_timeout
    stderr ||= '' if stderr_timeout

    started = false

    status =
      begin
        chdir(cwd) do
          Timeout::timeout(timeout) do
            popen4ext(closefds, *argv) do |c, i, o, e|
              started = true

              %w( replace pid= << push update ).each do |msg|
                break(pid.send(msg, c)) if pid.respond_to? msg
              end

              te = ThreadEnsemble.new c

              te.add_thread(i, stdin) do |i, stdin|
                relay stdin, i, stdin_timeout
                i.close rescue nil
              end

              te.add_thread(o, stdout) do |o, stdout|
                relay o, stdout, stdout_timeout
              end

              te.add_thread(e, stderr) do |o, stderr|
                relay e, stderr, stderr_timeout
              end

              te.run
            end
          end
        end
      rescue
        raise unless(not started and ignore_exec_failure)
      end

    raise SpawnError.new(cmd, status) unless
      (ignore_exit_failure or (status.nil? and ignore_exec_failure) or exitstatus.include?(status.exitstatus))

    status
  end
  module_function :spawn

  def chdir cwd, &block
    return(block.call Dir.pwd) unless cwd
    Dir.chdir cwd, &block
  end
  module_function :chdir

  def background arg, *argv
    require 'thread'
    q = Queue.new
    opts = { 'pid' => q, :pid => q }
    case argv.last
      when Hash
        argv.last.update opts
      else
        argv.push opts
    end
    thread = Thread.new(arg, argv){|arg, argv| spawn arg, *argv}
    sc = class << thread; self; end
    sc.module_eval {
      define_method(:pid){ @pid ||= q.pop }
      define_method(:spawn_status){ @spawn_status ||= value }
      define_method(:exitstatus){ @exitstatus ||= spawn_status.exitstatus }
    }
    thread
  end
  alias bg background
  module_function :background
  module_function :bg

  def maim pid, opts = {}
    getopt = getopts opts
    sigs = getopt[ 'signals', %w(SIGTERM SIGQUIT SIGKILL) ]
    suspend = getopt[ 'suspend', 4 ]
    pid = Integer pid
    existed = false
    sigs.each do |sig|
      begin
        Process.kill sig, pid
        existed = true
      rescue Errno::ESRCH
        return(existed ? nil : true)
      end
      return true unless alive? pid
      sleep suspend
      return true unless alive? pid
    end
    return(not alive?(pid))
  end
  module_function :maim

  def alive pid
    pid = Integer pid
    begin
      Process.kill 0, pid
      true
    rescue Errno::ESRCH
      false
    end
  end
  alias alive? alive
  module_function :alive
  module_function :'alive?'
end
