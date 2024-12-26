# def fixed_point_to_float(fixed_point, fractional_bits):
#     return fixed_point / (1 << fractional_bits)

# def float_to_fixed_point(float_val, fractional_bits):
#     return int(float_val * (1 << fractional_bits))

# 1 sign bit, 15 fractional bits, 1 integer bit
def fixed_point_to_float(fixed_point, fractional_bits):
    # sign 
    sign = fixed_point >> 16
    # integer
    integer = fixed_point >> fractional_bits & 0x1
    # fractional
    fractional = fixed_point & 0x7FFF
    return (1 - 2 * sign) * (integer + fractional / (1 << fractional_bits))



def bebrik(n):
    print(f"Fixed point: {bin(n)[2:].zfill(17)}")
    print(f"Value: {fixed_point_to_float(n, 15)}")
    print(f"Sign: {1 if n & (1 << 16) else 0}, dec: {n >> 15 & 0x1}")

# mx = float_to_fixed_point(-3.14 / 2, 15)
# print(mx)

bebrik(0x07f3f)
bebrik(0x07f3f & ~(1 << 15) | (1 << 16))
print()
bebrik(0x1)
bebrik(0x1 & ~(1 << 15) | (1 << 16))