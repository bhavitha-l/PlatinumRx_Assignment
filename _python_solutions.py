# 1. Convert minutes to human readable format
def convert_minutes(minutes):
    hrs = minutes // 60
    mins = minutes % 60

    if hrs > 0 and mins > 0:
        return f"{hrs} hr{'s' if hrs>1 else ''} {mins} minutes"
    elif hrs > 0:
        return f"{hrs} hr{'s' if hrs>1 else ''}"
    else:
        return f"{mins} minutes"

print(convert_minutes(130))


# 2. Remove duplicates from string
def unique_string(s):
    result = ""
    for char in s:
        if char not in result:
            result += char
    return result

print(unique_string("programming"))
