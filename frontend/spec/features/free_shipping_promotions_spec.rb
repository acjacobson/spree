require 'spec_helper'

describe 'Free shipping promotions', type: :feature, js: true do
  let!(:country) { create(:country, name: 'United States of America', states_required: true) }
  let!(:state) { create(:state, name: 'Alabama', country: country) }
  let!(:mug) { create(:product, name: 'RoR Mug', price: 20) }

  before do
    create(:zone)
    sm = create(:shipping_method)
    sm.calculator.preferred_amount = 10
    sm.calculator.save

    create(:check_payment_method)

    promotion = Spree::Promotion.create!(name: 'Free Shipping',
                                         starts_at: 1.day.ago,
                                         expires_at: 1.day.from_now)

    action = Spree::Promotion::Actions::FreeShipping.new
    action.promotion = promotion
    action.save

    promotion.reload # so that promotion.actions is available
  end

  context 'free shipping promotion automatically applied' do
    include_context 'proceed to payment step'

    # Regression test for #4428
    it 'applies the free shipping promotion' do
      within('#checkout-summary') do
        page.has_text? 'SHIPPING: $10.00'
        page.has_text? 'Promotion (Free Shipping): -$10.00'
      end
    end
  end
end
