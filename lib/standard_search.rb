module StandardSearch
  extend ActiveSupport::Concern 

  included do 
    include Searchable
  end

  module ClassMethods
    # scope: scope 对象
    # q: 搜索的字符串
    # count: 返回的个数
    # offset: 从查询结果的第offset个开始
    def standard_search(scope, q, count, offset)
      param = {
        :query => {
          :multi_match => {
            :fields   => standard_fields,
            :type     => "cross_fields",
            :query    => q,
            :analyzer => "standard",
            :operator => "and"
          }
        }
      }

      self.search(param).records.all
    end

    def standard(*fields)
      standard_fields.merge fields

      settings :index => {:number_of_shards => 1} do
        mappings :dynamic => "false" do
          fields.each do |f|
            indexes f, :analyzer => "chinese"
          end
        end
      end
    end

    def standard_fields
      @_standard_fields ||= Set.new
    end
  end
end
