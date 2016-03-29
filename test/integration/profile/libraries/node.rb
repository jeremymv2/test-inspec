class NodeAttributes < Inspec::Resources::JsonConfig
  name 'node'
  def initialize
    super('/tmp/node.json')
  end
end
