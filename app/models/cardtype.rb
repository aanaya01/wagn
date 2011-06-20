class Cardtype < ActiveRecord::Base
  self.extend Wagn::Card::ActsAsCardExtension 
  acts_as_card_extension  
  cattr_reader :cache
  #  before_filter :load_cache_if_empty, :only=>[:name_for, :class_name_for, :create_party_for, :createable_typecodes, :create_ok? ]
  
  @@cache={}
  
  class << self
    def reset_cache
      @@cache={}
    end
    
    def load_cache
      @@cache = {   
        :card_keys => {},
        :card_names => {},
        :class_names => {},
        :create_parties => {},
      }

      Card.connection.select_all(%{
        select distinct ct.class_name, c.name, c.key, p.party_type, p.party_id 
        from cardtypes ct 
        join cards c on c.extension_id=ct.id and c.typecode='Cardtype'    
        join permissions p on p.card_id=c.id and p.task='create' 
      }).each do |rec|
        @@cache[:card_keys][rec['key']] = rec['name']
        @@cache[:card_names][rec['class_name']] = rec['name'];   
        @@cache[:class_names][rec['key']] = rec['class_name']
        @@cache[:create_parties][rec['class_name']] = rec['party_id']
        ## error check
        unless rec['party_type'] == 'Role'
          raise "Bad Data: create permission for #{rec['class_name']} " +
            "should have party_type 'Role' not '#{rec['party_type']}'"
        end
      end

      #@@cache[:class_names].values.sort.each do |name|
      #  Card.class_for(name)
      #end
    end

    def name_for_key?(key)
      load_cache if @@cache.empty?      
      @@cache[:card_keys].has_key?(key)
    end

    def name_for_key(key)
      load_cache if @@cache.empty?
      @@cache[:card_keys][key] || 'Basic' #raise("No card name for key #{key}")
    end
    
    def name_for(classname)
      load_cache if @@cache.empty?
      Rails.logger.debug "name_for (#{classname.inspect}) #{@@cache[:card_names].inspect}"
      @@cache[:card_names][classname] || 'Basic' # raise("No card name for class #{classname}") 
    end

    def classname_for(card_name) 
      load_cache if @@cache.empty?
      @@cache[:class_names][card_name.to_key] || nil #raise("No class name for cardtype name #{card_name}") 
    end
    
    def create_party_for(class_name)
      load_cache if @@cache.empty?
      @@cache[:create_parties][class_name] || raise("No create party for class #{class_name}") 
    end    
    
    def createable_cardtypes  
      load_cache if @@cache.empty?
      @@cache[:card_names].collect do |class_name,card_name|
        next if ['InvitationRequest','Setting','Set'].include?(class_name)
        next unless create_ok?(class_name)
        { :codename=>class_name, :name=>card_name }
      end.compact.sort_by {|x| x[:name].downcase }
    end   
    
    def create_ok?(typecode, cardname=nil)
      typecode = classname_for(cardname)||'Basic' unless typecode
      load_cache if @@cache.empty?
      System.role_ok?(@@cache[:create_parties][typecode].to_i)
    end
  end        
  
  def codename
    class_name
  end
  
end
