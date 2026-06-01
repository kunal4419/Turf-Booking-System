import re
import os

with open('../documentation/backend_connection.md', 'r') as f:
    content = f.read()

# Regular expression to find file paths and their corresponding dart code blocks
# Looking for patterns like `lib/path/to/file.dart` followed by ```dart ... ```
pattern = re.compile(r'`(lib/[^`]+)`\)\s*```dart\n(.*?)```', re.DOTALL)

matches = pattern.findall(content)

for file_path, code in matches:
    full_path = os.path.join(os.getcwd(), file_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(code.strip() + '\n')
    print(f"Created/Updated {file_path}")

print("Done extracting files from markdown!")
