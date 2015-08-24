require 'minitest/autorun'
require 'tempest'

class TestInheritanceIndirect < Minitest::Test
  def test_parameter_inheritance
    Tempest::Library.new(:test_parameter_indirect_inheritance_inner) do
      parameter(:bar).create(:string, :description => "Test parameter")
    end
    Tempest::Library.new(:test_parameter_indirect_inheritance_outer) do
      use library(:test_parameter_indirect_inheritance_inner)
    end

    tmpl = Tempest::Template.new do
      use library(:test_parameter_indirect_inheritance_outer)
      resource(:foo).create('AWS::EC2::Instance', :bar => parameter(:bar))
    end

    expected_output = {
      "Resources" => {
        "Foo" => {
          "Type" => 'AWS::EC2::Instance',
          "Properties" => {
            "Bar" => { 'Ref' => 'Bar' }
          }
        }
      },
      "Parameters" => {
        "Bar" => {
          "Type" => "String",
          "Description" => "Test parameter"
        }
      }
    }

    assert_equal(tmpl.to_h, expected_output)
  end

  def test_mapping_inheritance
    Tempest::Library.new(:test_mapping_indirect_inheritance_inner) do
      mapping(:bar).create(
        'Bar' => {
          'Baz' => 'Quux'
        }
      )
    end
    Tempest::Library.new(:test_mapping_indirect_inheritance_outer) do
      use library(:test_mapping_indirect_inheritance_inner)
    end
    tmpl = Tempest::Template.new do
      use library(:test_mapping_indirect_inheritance_outer)
      resource(:foo).create('AWS::EC2::Instance', :bar => mapping(:bar).find('Bar', 'Baz'))
    end

    expected_output = {
      "Resources" => {
        "Foo" => {
          "Type" => 'AWS::EC2::Instance',
          "Properties" => {
            "Bar" => { "Fn::FindInMap" => ['Bar', 'Bar', 'Baz'] }
          }
        }
      },
      "Mappings" => {
        "Bar" => {
          "Bar" => {
            "Baz" => "Quux"
          }
        }
      }
    }

    assert_equal(tmpl.to_h, expected_output)
  end

  def test_condition_inheritance
    Tempest::Library.new(:test_condition_indirect_inheritance_inner) do
      condition(:bar).equals('Bar', 'Baz')
    end
    Tempest::Library.new(:test_condition_indirect_inheritance_outer) do
      use library(:test_condition_indirect_inheritance_inner)
    end
    tmpl = Tempest::Template.new do
      use library(:test_condition_indirect_inheritance_outer)
      resource(:foo).create(
        'AWS::EC2::Instance',
        :condition => condition(:bar),
        :bar       => condition(:bar).if('Quux', 'Quuz')
      )
    end

    expected_output = {
      'Resources' => {
        'Foo' => {
          'Type' => 'AWS::EC2::Instance',
          'Properties' => {
            'Condition' => 'Bar',
            'Bar' => {
              'Fn::If' => [
                'Bar',
                'Quux',
                'Quuz'
              ]
            },
          }
        }
      },
      'Conditions' => {
        'Bar' => {
          'Fn::Equals' => [
            'Bar',
            'Baz'
          ]
        }
      }
    }

    assert_equal(tmpl.to_h, expected_output)
  end
end
