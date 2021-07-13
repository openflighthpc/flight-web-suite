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

module FlightWebSuite
  module Commands
    class Service < Command
      def self.start(args, opts, _)
        opts.command = 'start'
        new(args, opts).run!
      end

      def self.stop(args, opts, _)
        opts.command = 'stop'
        new(args, opts).run!
      end

      def self.restart(args, opts, _)
        opts.command = 'restart'
        new(args, opts).run!
      end

      def self.reload(args, opts, _)
        opts.command = 'reload'
        new(args, opts).run!
      end

      def self.enable(args, opts, _)
        opts.command = 'enable'
        new(args, opts).run!
      end

      def self.disable(args, opts, _)
        opts.command = 'disable'
        new(args, opts).run!
      end

      def run
        services.each do |service|
          system(*Flight.config.service_command, opts.command, service)
        end
      end

      def services
        return Flight.config.services if args.empty?
        diff = args - Flight.config.services
        return args if diff.empty?
        raise InputError, "The following are not web-suite services: #{diff.join(',')}"
      end
    end
  end
end

