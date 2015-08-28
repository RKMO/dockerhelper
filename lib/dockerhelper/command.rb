require 'open3'

module Dockerhelper
  class Command
    attr_reader :cmd, :label, :chdir

    def initialize(cmd, label: '', chdir: Dir.pwd)
      @label = " #{label}" if label.size > 0
      @cmd = cmd
      @chdir = chdir
    end

    def capture
      stdout, stderr, status = Open3.capture3(cmd)
      pid = status.pid
      cmd_prefix = "[#{pid}#{label}]"

      $stdout.puts ">> #{yellow(cmd_prefix)} cwd: #{chdir} cmd: #{cmd}"
      unless stdout.empty?
        stdout.lines.each do |line|
          $stdout.puts "   #{green(cmd_prefix)} #{line}"
        end
      end

      unless stderr.empty?
        stderr.lines.each do |line|
          $stderr.puts "   #{red(cmd_prefix)} #{line}"
        end
      end

      $stdout.puts "<< #{yellow(cmd_prefix)} exit_status: #{status}"
      stdout
    end

    def run
      Open3.popen3(cmd, chdir: chdir) do |stdin, stdout, stderr, wait_thr|
        pid = wait_thr.pid
        cmd_prefix = "[#{pid}#{label}]"
        $stdout.puts ">> #{yellow(cmd_prefix)} cwd: #{chdir} cmd: #{cmd}"

        stdin.close
        stderr_thr = Thread.new do
          while line = stderr.gets
            $stderr.puts "   #{red(cmd_prefix)} #{line}"
          end
        end

        stdout_thr = Thread.new do
          while line = stdout.gets
            $stdout.puts "   #{green(cmd_prefix)} #{line}"
          end
        end

        stderr_thr.join
        stdout_thr.join

        exit_status = wait_thr.value
        $stdout.puts "<< #{yellow(cmd_prefix)} exit_status: #{exit_status}"

        raise "Non-zero exit status; terminating." unless exit_status.success?
      end
    end

    def colorize(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def red(text); colorize(text, 31); end
    def green(text); colorize(text, 32); end
    def yellow(text); colorize(text, 33); end
  end
end
