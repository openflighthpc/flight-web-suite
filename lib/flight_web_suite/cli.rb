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
require_relative 'configuration'
require_relative 'version'

require 'commander'
require_relative 'help_formatter'

module FlightWebSuite
  module CLI
    extend Commander::CLI

    def self.create_command(name, args_str = '')
      command(name) do |c|
        c.syntax = "#{program :name} #{name} #{args_str}"
        c.hidden if name.split.length > 1

        c.action do |args, opts|
          require_relative '../flight_web_suite'
          begin
            const_string = FlightWebSuite.constantize(c.name)
            command = FlightWebSuite::Commands.const_get(const_string).new(args, opts)
          rescue NameError
            FlightWebSuite.logger.fatal "Command class not defined (maybe?): FlightWebSuite::Commands::#{const_string}"
            raise InternalError.define_class(127), 'Command Not Found!'
          end
          command.run!
        end

        yield c if block_given?
      end
    end

    program :name,         ENV.fetch('FLIGHT_PROGRAM_NAME') { 'bin/web-suite' }
    program :application,  'Flight Web Suite'
    program :description,  'Manage the Web Suite services'
    program :version, "v#{FlightWebSuite::VERSION}"
    program :help_paging, false
    default_command :help

    # NOTE: There is a bug in Commander where the help formatter aliases aren't set
    @help_formatter_aliases = {}
    program :help_formatter, HelpFormatter

    if [/^xterm/, /rxvt/, /256color/].all? { |regex| ENV['TERM'] !~ regex }
      Paint.mode = 0
    end

    create_command 'info-domain' do |c|
      c.summary = 'View the current web-suite domain'
    end

    create_command 'set-domain', 'DOMAIN' do |c|
      c.summary = 'Set the web-suite domain'
    end

    if Flight.env.development?
      create_command 'console' do |c|
        c.action do |args, opts|
          require_relative 'command'
          require_relative '../flight_web_suite'
          FlightWebSuite::Command.new(args, opts).instance_exec { binding.pry }
        end
      end
    end
  end
end
