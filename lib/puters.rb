class Puters

  def ec2_client
    configs = YAML.load_file('./credentials.yml')

    id = configs['credentials']['id']
    key = configs['credentials']['key']
    region = configs['credentials']['region']

    creds = Aws::Credentials.new(id, key)
    ec2 = Aws::EC2::Client.new(region: region, credentials: creds)
  end

  def fetch_cluster_ips(client, env, tags)
    data = []
    reservations = aws_fetch_by_name_and_env(client, env, tags)

    reservations.each do |reservation|
      reservation.instances.each do |instance|
        row = {}
        instance.tags.map { |t| row[:name] = t.value if t.key == 'Name' }
        row[:ip] = instance.private_ip_address
        row[:instance_id] = instance.instance_id
        row[:instance_type] = instance.instance_type
        row[:zone] = instance.placement.availability_zone
        row[:network_interfaces] = network_interfaces(instance.network_interfaces)
        row[:security_groups] = security_groups(instance.security_groups)
        row[:block_device_mappings] = block_device_mappings(instance.block_device_mappings)
        data << row
      end
    end

    data
  end

  def display data
    # Padding
    pad_name = 35
    pad_ip = 17
    pad_instanceid = 15
    pad_zone = 15
    pad_type = 15
    pad_subnet = 20
    pad_sec_groups = 30
    pad_volumes = 30

    # Header
    puts  'Name'.ljust(pad_name) +
          'IP'.ljust(pad_ip) +
          'Instance ID'.ljust(pad_instanceid) +
          'Zone'.ljust(pad_zone) +
          'Instance Type'.ljust(pad_type) +
          'Subnet'.ljust(pad_subnet) +
          'Security Groups'.ljust(pad_sec_groups) +
          'Volumes'.ljust(pad_volumes)

    # Body
    data.each do |row|
      puts  row[:name].ljust(pad_name) +
            row[:ip].ljust(pad_ip) +
            row[:instance_id].ljust(pad_instanceid) +
            row[:zone].ljust(pad_zone) +
            row[:instance_type].ljust(pad_type) +
            row[:network_interfaces].ljust(pad_subnet) +
            row[:security_groups].ljust(pad_sec_groups) +
            row[:block_device_mappings].ljust(pad_volumes)

    end

  end

  private

  def aws_fetch_by_name_and_env(client, env, tags)
    filters = []
    filters << { name: "tag:Environment", values: [env] }
    tags.map { |k,v| filters << search_by_tag(k, v) }

    client.describe_instances(filters: filters).reservations
  end

  def search_by_tag(tag, search_term)
    { name: "tag:#{tag.capitalize}", values: ["#{search_term}"] }
  end

  def security_groups security_groups
    sgs = []
    security_groups.map { |g| sgs << g.group_id unless g.group_id.nil? }
    sgs*','
  end

  def network_interfaces network_interfaces_data
    nis = []
    key = 'subnet_id'
    # network_interfaces_data.map { |g| nis << g.key unless g.subnet_id.nil? }
    network_interfaces_data.map { |g| nis << g.subnet_id unless g.subnet_id.nil? }
    nis*','
  end

  def block_device_mappings block_device_mappings_data
    data = []
    block_device_mappings_data.map { |b| data << b.ebs.volume_id unless b.ebs.volume_id.nil? }
    data*','
  end

end

