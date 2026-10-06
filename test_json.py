import json
with open('out.txt', 'r', encoding='utf-16') as f:
    text = f.read()
print(f"Length of output: {len(text)}")
try:
    if '[' in text:
        arr_str = text[text.find('['):]
        arr = json.loads(arr_str)
        print(f"Number of cities: {len(arr)}")
        print(f"First city keys: {list(arr[0].keys())}")
    elif '{' in text:
        obj_str = text[text.find('{'):]
        obj = json.loads(obj_str)
        print(f"Keys: {list(obj.keys())}")
        if 'data' in obj:
            print(f"Data length: {len(obj['data'])}")
            if len(obj['data']) > 0:
                print(f"First item keys: {list(obj['data'][0].keys())}")
except Exception as e:
    print(f"Error parsing: {e}")
