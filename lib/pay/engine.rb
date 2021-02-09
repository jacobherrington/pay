# frozen_string_literal: true

module Pay
  class Engine < ::Rails::Engine
    engine_name "pay"

    paths.add "lib", eager_load: true

    initializer "pay.processors" do |app|
      if Pay.automount_routes
        app.routes.append do
          mount Pay::Engine, at: Pay.routes_path, as: "pay"
        end
      end
    end

    config.to_prepare do
      Pay::Processors::Stripe.setup if defined? ::Stripe
      Pay::Processors::Braintree.setup if defined? ::Braintree
      Pay::Processors::Paddle.setup if defined? ::PaddlePay

      Pay.charge_model.include Pay::Receipts if defined? ::Receipts::Receipt
    end
  end
end
