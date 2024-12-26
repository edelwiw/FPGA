def fixed_point_to_float(fixed_point, fractional_bits):
    return fixed_point / (1 << fractional_bits)

def float_to_fixed_point(float_val, fractional_bits):
    return int(float_val * (1 << fractional_bits))

print(fixed_point_to_float(19898, 15))
print(float_to_fixed_point(0.60723876953125, 15))

mx = float_to_fixed_point(3.14, 15)
print(mx)
