import json
import argparse
from jsonschema import validate, ValidationError

def read_json_file(file_path):
    with open(file_path, 'r') as file:
        try:
            data = json.load(file)
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON syntax in the file: {file_path}") from e
    return data

def validate_json_file(json_file, schema_file):
    try:
        json_data = read_json_file(json_file)
    except ValueError as e:
        print(str(e))
        exit()
    with open(schema_file, 'r') as file:
        schema = json.load(file)

    try:
        validate(json_data, schema)
        print(f"Validation successful: {json_file} matches the schema {schema_file}.")
    except ValidationError as e:
        print(f"Validation failed: {json_file} does not match the schema {schema_file}.")
        print("Validation error details:", e)

def main():
    parser = argparse.ArgumentParser(description='Validate JSON files against schemas.')
    parser.add_argument('json_file', type=str, help='Path to the JSON file to validate')
    parser.add_argument('schema_file', type=str, help='Path to the JSON schema file')
    args = parser.parse_args()

    validate_json_file(args.json_file, args.schema_file)

if __name__ == '__main__':
    main()

