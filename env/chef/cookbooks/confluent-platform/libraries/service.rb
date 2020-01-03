# frozen_string_literal: true

#
# Copyright (c) 2017-2018 Make.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Module used to create all services
module ConfluentPlatformService
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def create_service(component)
    # Configuration files to be subscribed
    node.run_state[cookbook_name] ||= {}
    node.run_state[cookbook_name][component] ||= {}
    conf_files = node.run_state[cookbook_name][component]['conf_files']
    template_files = (conf_files || {}).map { |path| "template[#{path}]" }

    # return if something was interrupted (config probably)
    return if node.run_state[cookbook_name][component]['interrupted']

    # Configure systemd unit with options
    unit = node[cookbook_name].dig(component, 'unit').to_hash || {}
    unit = unit.merge(
      node.run_state.dig(cookbook_name, component, 'unit') || {}
    )
    unit['Service']['ExecStart'] = [
      unit['Service']['ExecStart']['start'],
      (node[cookbook_name].dig(component, 'cli_opts') || {}).map do |key, opt|
        # remove key if value is string 'nil' (using 'string' is not a bug)
        "#{key}#{"=#{opt}" unless opt.to_s.empty?}" unless opt == 'nil'
      end,
      unit['Service']['ExecStart']['end']
    ].flatten.compact.join(" \\\n  ")

    auto_r = node.run_state[cookbook_name].dig(component, 'auto_restart')
    auto_r = node[cookbook_name].dig(component, 'auto_restart') if auto_r.nil?

    # Create unit
    unit_name =
      case component
      when 'rest' then 'kafka-rest'
      when 'registry' then 'schema-registry'
      when 'connect' then 'kafka-connect'
      else component
      end

    r_resources =
      node.run_state.dig(cookbook_name, component, 'restart_resources') || []
    r_resources += template_files

    log "#{unit_name} will be restarted" do
      action :nothing
      r_resources.each { |r| subscribes(:write, r, :immediately) } if auto_r
      only_if "systemctl is-active #{unit_name}"
    end

    systemd_unit "#{unit_name}.service" do
      enabled true
      active true
      masked false
      static false
      content unit
      triggers_reload true
      action %i[create enable start]
      subscribes :restart, "log[#{unit_name} will be restarted]"
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity
