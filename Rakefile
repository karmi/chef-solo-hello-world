task :default => :steps

begin
  require 'term/ansicolor'
  class String
    include Term::ANSIColor
  end
rescue LoadError
  class String
    def bold; self; end
    def black; self; end
    def white; self; end
    def on_green; self; end
    def on_yellow; self; end
    def on_magenta; self; end
  end
end

_ = '-'*80

desc "List the steps of this tutorial"
task :steps do
  puts _, "Steps of this tutorial", _
  current = GitSteps.current_step

  GitSteps.steps.each_with_index do |step, i|
    is_current = step.sha == current.sha ? "*" : " "
    puts "#{is_current} #{(i+1).to_s.rjust(3).bold} | #{step.subject.gsub(/^\[\d+\] /, '')}"
  end

  puts _, "Use `rake start` to start the tutorial.", _
end

desc "Display current step"
task :step => [:check] do
  step = GitSteps.current_step
  puts _, "#{step.sha} | #{step.subject.bold}",
       _, "#{step.body}"
end

desc "Start the tutorial or switch back to first step"
task :start => [:check] do
  puts _, "Starting the tutorial with the first step".white.on_magenta, _
  step = GitSteps.steps.first
  puts "#{step.sha} | #{step.subject.bold}",
       "#{step.body}"
  system "git checkout #{step.sha} > /dev/null 2>&1 "
  puts   _, "Use `rake next` to load the next step. Use `rake reset` to reset the tutorial.", _
end

desc "Step to the next step of tutorial"
task :next => [:check] do
  if step = GitSteps.next_step
    puts _, "#{step.sha} | #{step.subject.bold}",
         _, "#{step.body}"
    exec "git checkout #{step.sha} > /dev/null 2>&1 "
  else
    puts "You have reached the end of the tutorial".white.on_green,
         "Start again with: rake start"
  end
end

desc "Step to the previous step of tutorial"
task :previous => [:check] do
  if step = GitSteps.previous_step
    puts _, "#{step.sha} | #{step.subject.bold}",
         _, "#{step.body}"
    exec "git checkout #{step.sha} > /dev/null 2>&1 "
  else
    puts "You are at the beginning of the tutorial".white.on_green,
         "Follow the tutorial with: rake next"
  end
end

desc "Show differences between the current step and the previous step"
task :diff do
  current = GitSteps.current_step
  previous = GitSteps.previous_step
  puts _, "Previous : #{previous.subject}",
          "Current  : #{current.subject}", _
  exec "git diff --color --ignore-all-space --minimal HEAD^ HEAD | cat"
end

desc "Reset the tutorial and switch to master branch"
task :reset => [:check] do
  exec "git checkout master > /dev/null"
end

task :check do
  if `which git` == ''
    puts "[!] ERROR: You need Git installed to step through the tutorial.".white.on_red
    exit(1)
  end
end

module GitSteps
  class Commit
    attr_reader :sha, :subject, :body
    def initialize(commit)
      @sha, @subject = commit.split('|||', 2)
      @body          = %x[git log -n 1 --format='%b' #{sha}].chomp
    end
    def step?; subject =~ /^\[\d+\]/; end
  end

  def steps
    %x[git log --reverse --format='%h|||%s' master]
      .chomp
      .split("\n")
      .map    { |commit| Commit.new(commit) }
      .select { |commit| commit.step? }
  end

  def current_step
    Commit.new( %x[git log -n 1--reverse --format='%h|||%s'].chomp )
  end

  def next_step
    steps.select { |step| step.subject > current_step.subject }.first
  end

  def previous_step
    steps.select { |step| step.subject < current_step.subject }.last
  end

  extend self
end
