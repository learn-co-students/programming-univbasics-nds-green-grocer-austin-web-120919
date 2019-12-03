def find_item_by_name_in_collection(name, collection)
  i=0
  result = nil
  while i < collection.length do
    if name == collection[i][:item]
      result = collection[i]
      break
    else
      i += 1
    end
  end
  result
end

def consolidate_cart(cart)
  i = 0
  result_aoh = []
  while i < cart.length
    cart_item = cart[i][:item]
    lookup_item = find_item_by_name_in_collection(cart_item,result_aoh)
    if lookup_item
      lookup_item[:count] += 1
    else
      cart[i][:count] = 1
      result_aoh << cart[i]
    end
    i += 1
  end
  result_aoh
end

def mk_coupon_hash(c)
  rounded_unit_price = (c[:cost].to_f * 1.0 / c[:num]).round(2)
  {
    :item => "#{c[:item]} W/COUPON",
    :price => rounded_unit_price,
    :count => c[:num]
  }
end

# A nice "First Order" method to use in apply_coupons

def apply_coupon_to_cart(matching_item, coupon, cart)
  matching_item[:count] -= coupon[:num]
  item_with_coupon = mk_coupon_hash(coupon)
  item_with_coupon[:clearance] = matching_item[:clearance]
  cart << item_with_coupon
end

def apply_coupons(cart, coupons)
  i = 0
  while i < coupons.count do
    coupon = coupons[i]
    item_with_coupon = find_item_by_name_in_collection(coupon[:item], cart)
    item_is_in_basket = !!item_with_coupon
    count_is_big_enough_to_apply = item_is_in_basket && item_with_coupon[:count] >= coupon[:num]

    if item_is_in_basket and count_is_big_enough_to_apply
      apply_coupon_to_cart(item_with_coupon, coupon, cart)
    end
    i += 1
  end
  cart
end

def apply_clearance(cart)
  i = 0
  result = []
  while i < cart.length do
    if cart[i][:clearance]
      clearance_price = ((cart[i][:price]) * (1 - 0.2)).round(2)
      cart[i][:price] = clearance_price
      result << cart[i]
    else
      result << cart[i]
    end
    i += 1
  end
  result
end

def cost_of_items(i)
  i[:count] * i[:price]
end

def checkout(cart, coupons)
  total = 0
  i = 0
  c_cart = consolidate_cart(cart)
  apply_coupons(c_cart,coupons)
  apply_clearance(c_cart)

  while i < c_cart.length do
    total += cost_of_items(c_cart[i])
    i += 1
  end

  total > 100 ? (total * (1 - 0.1)).round(2) : total

end
