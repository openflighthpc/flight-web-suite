#==============================================================================
# Copyright (C) 2021-present Alces Flight Ltd.
#
# This file is part of Flight Web Suite.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Web Suite is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Web Suite. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Web Suite, please visit:
# https://github.com/openflighthpc/flight-web-suite
#==============================================================================
# This help formatter has been modified from commander-openflighthpc. All
# changes are made available under the EPL-2.0 mentioned above. The original
# work is available under the following licenses.
#
# The following license applies to changes made subsequent to the point
# this version was forked from the original upstream version available
# at <https://github.com/commander-rb/commander>.
#
# The MIT License (MIT)
#
# Copyright (c) 2017-present Alces Flight Ltd <licensing@alces-flight.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# The original license from the upstream version is included below:
#
# The MIT License (MIT)
#
# Copyright (c) 2008-2013 TJ Holowaychuk <tj@vision-media.ca>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#==============================================================================

module Commander
  # Patch the section method onto Commander::Command
  class Command
    attr_writer :section

    # NOTE: Provide the program implicitly once extracted
    attr_accessor :program

    def section
      return @section if @section
      # This is required as 'help' is defined before applying the patch
      # Remove when extracted
      return :__other__ unless program

      # Find the longest matching section key/alias suffix
      last = nil
      cur = name
      until last == cur do
        @section = program.section_keys_map[cur]
        return @section if @section
        last = cur
        cur = cur.split(/[_-]/, 2).last
      end
      @section = :__other__
    end
  end

  # Patch the section method onto Commander::CLI
  module CLI
    def section(key, desc, aliases: [])
      section_keys_map[key.to_s] = key
      aliases.each { |a| section_keys_map[a.to_s] = key }

      # Return the description
      sections[key] = desc
    end

    def sections
      @sections ||= {}
    end

    def section_keys_map
      @section_keys_map ||= {}
    end

    def run(*args)
      instance = Runner.new(
        @program, commands, default_command,
        global_slop, aliases, args
      )
      # NOTE: Clean this method up when extracted
      instance.sections = sections
      instance.run
    end
  end

  # Patch the helper methods onto Commander::CLI
  class Runner
    attr_accessor :sections

    def commands_by_section
      keys = sections.keys
      max = keys.length
      commands.each_with_object({}) do |(_, cmd), memo|
        memo[cmd.section] ||= []
        memo[cmd.section] << cmd
      end.sort_by { |k, _| keys.index(k) || max }.to_h
    end
  end
end

module FlightWebSuite
  class ProgramContext < Commander::HelpFormatter::ProgramContext
  end

  class HelpFormatter < Commander::HelpFormatter::Terminal
    PROGRAM_HELP = ERB.new(<<~'RUBY', nil, '-')
<%=
  if !program(:nobanner)
    begin
      require 'openflight/banner'
      OpenFlight::Banner.render(title: program(:application), version: program(:version))
    rescue LoadError
      nil
    end
  end
-%>
  <%= $terminal.color "NAME", :bold %>:

    <%= program :name %>

  <%= $terminal.color "DESCRIPTION", :bold %>:

    <%= Commander::HelpFormatter.indent 4, program(:description) %>

  <%= $terminal.color "COMMANDS", :bold %>:
<% for section, commands in commands_by_section do -%>

    <%= $terminal.color("#{sections[section] || 'Miscellaneous:'}", :bold) %>
<%   for command in commands do -%>
    <%= "%-#{max_command_length}s %s" % [command.name, command.summary || command.description] %>
<%   end -%>
<% end %>
<% unless @aliases.empty? -%>
  <%= $terminal.color "ALIASES", :bold %>:
  <% for alias_name, args in @aliases.sort %>
    <%= "%-#{max_aliases_length}s %s %s" % [alias_name, command(alias_name).name, args.join(' ')] -%>
  <% end %>
<% end %>
<% unless global_slop.options.empty? -%>
  <%= $terminal.color "GLOBAL OPTIONS", :bold %>:
	<% global_slop.options.each do |global| -%>

<% tag = if [Slop::BoolOption, Slop::NullOption]
           nil
         elsif meta = option.config[:meta]
           meta
         else
           option.key.upcase
         end
-%>
    <%= global.flags.join ', ' %> <%= tag %>
        <%= Commander::HelpFormatter.indent 8, global.desc %>
	<% end -%>
<% end -%>
<% if program :help -%>
  <% for title, body in program(:help) %>
  <%= $terminal.color title.to_s.upcase, :bold %>:

    <%= body %>
  <% end -%>
<% end %>
RUBY

    def render
      ctx = ProgramContext.new(@runner)
      PROGRAM_HELP.result(ctx.get_binding)
    end

    # NOTE: Do not override the following methods as they render they render
    # the individual commands
    # def render_command(command)
    #   super
    # end
    #
    # def template(name)
    #   super
    # end
  end
end
