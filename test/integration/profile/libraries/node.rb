#class NodeAttributes < Inspec::Resources::JsonConfig
class NodeAttributes < JsonConfig
  name 'node'
  def initialize
    super('/tmp/node.json')
  end
end
