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
    class SetDomain < Command
      def self.set(args, opts, _)
        new(args, opts).run!
      end

      def run
        run_cert_gen
        run_config_set
        puts "Your domain has been updated! The web service can be restarted with:"
        puts pastel.yellow "#{CLI.program(:name)} restart"
      end

      private

      def run_cert_gen
        cmd = [*Flight.config.www_command, 'cert-gen', '--domain', args.first]
        cmd.concat(['--email', opts.email]) if opts.email
        cmd.concat(['--cert-type', opts.cert_type]) if opts.cert_type
        str = cmd.join(' ')
        Flight.logger.info "Running: #{str}"
        # NOTE: flight-www doesn't emit its errors to STDERR :(
        # As this *may* change without warning, it is best to merge stdout/stderr
        out, status = Open3.capture2e(*cmd)
        log_command(str, status, out, '')
        if !status.success? && out.include?('--email')
          raise InputError, <<~ERROR.chomp
            Can not generate a LetsEncrypt certificate without an email address!
            Please provide one of the following flags: #{pastel.yellow("--cert-type self-signed | --email EMAIL")}
          ERROR
        elsif !status.success?
          # NOTE: Prompting the user to run the command manually and then again through set-domain
          # *may* cause the SSL certificate to be issued twice.
          #
          # This *could* cause issues for LetsEncrypt certificates as they are rate limited for a
          # specified domain (IIRC 5 times per month per domain). The most likely reason why the
          # command has failed is 'flight-www' isn't actively running OR the domain is already
          # rated limited.
          #
          # Revisit as required.
          raise CommandError, <<~ERROR.chomp
            Failed to generate a SSL certificate! Please ensure the following works before continuing:
            #{pastel.yellow str}
          ERROR
        end
      end

      def run_config_set
        cmd = [*Flight.config.config_command, 'set', 'web-suite.domain', args.first]
        str = cmd.join(' ')
        Flight.logger.info "Running: #{str}"
        out, err, status = Open3.capture3(*cmd)
        log_command(str, status, out, err)
        raise CommandError, "Failed to run command: #{str}" unless status.success?
      end
    end
  end
end
