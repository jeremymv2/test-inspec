# test-inspec

Some working examples of using inspec.  Also, using an embedded compliance profile.

clone down the repo and run `chef gem install kitchen-inspec` then `kitchen converge` and `kitchen verify`

## Embedded inspec compliance profile

`kitchen-inspec` (v0.12.2) allows for embedding a compliance profile, running it alongside other integration tests.
The advantage of this is ease of testing your profiles in kitchen.  Additionally compliance profiles allow you to write
custom libraries to add or extend existing inspec functionality.

The directory structure looks like this:
```
$ tree test/
test/
└── integration
    ├── default
    │   └── default_spec.rb
    └── profile
        ├── README.md
        ├── controls
        │   └── default.rb
        ├── inspec.yml
        └── libraries
            └── node.rb

5 directories, 5 files
```
You can test the embedded profile by adding it to your .kitchen.yml:
```
suites:
  - name: profile
    run_list:
      - recipe[test-inspec::profile]
```

Verify as usual that your profile is valid:
```
$ inspec check test/integration/profile
Summary
-------
Location: test/integration/profile
Profile: myprofile
Controls: 6
Timestamp: 2016-02-23T11:09:07-05:00
Valid: true

Errors
------

Warnings
--------
```

As mentioned, one added benefit of embedded profiles is that you gain the ability to write custom libraries.
Here's an example of how that can be useful:

Let's pretend you have a recipe that installs vim-minimal with version specified by attribute then
writes the node attributes to a file:
```
# recipes/profile.rb
package 'vim-minimal' do
  version node['vim']['version']
  action :install
end

# dump the node object to file
output="#{Chef::JSONCompat.to_json_pretty(node.to_hash)}"
file '/tmp/node.json' do
  content output
end
```

You could then create an inspec class library file that inherits from the `JsonConfig` class and parses
the above `/tmp/node.json` for you, creating a Json object.
```
# test/integration/profile/libraries/node.rb
class NodeAttributes <JsonConfig
  name 'node'
  def initialize
    super('/tmp/node.json')
  end
end
```

Now you are able to use the `node` json object in any of your inspec tests like so:
```
# test/integration/profile/controls/default.rb
describe package('vim-minimal') do
  it { should be_installed }
  its('version') { should eq node.value(['vim','version']) }
end
```
