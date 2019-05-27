module OrderControllerClient
  def self.included(host)
    @is_defined_cart_path = host.new.respond_to? :cart_path
    #puts "is_defined_cart_path=#{@is_defined_cart_path}"
    # pass this flag from CustomClient to host :
    host.instance_variable_set(:@is_defined_cart_path,
                               @is_defined_cart_path)
    host.class_eval do
      old_cart_path = instance_method(:cart_path) if @is_defined_cart_path
      define_method(:cart_path) do |*args|
        if params[:return_to_product].present?
          flash[:success] = "Added to cart"
          params[:return_to_product]
        else
          if self.class.instance_variable_get(:@is_defined_cart_path)
            old_cart_path.bind(self).call(*args)
          else
            "/cart"
          end
        end
      end
    end
  end
end
