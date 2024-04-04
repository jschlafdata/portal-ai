import os
import sys
import json

def log_to_stderr(message):
    sys.stderr.write(message + "\n")

def list_sub_charts(sub_chart_dir):
    entries = os.listdir(sub_chart_dir)
    
    sub_charts = [entry for entry in entries if os.path.isdir(os.path.join(sub_chart_dir, entry))]
    
    return sub_charts

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(1)

    sub_chart_dirs = sys.argv[1].split('.')
    sub_chart_dir = os.path.join(sub_chart_dirs[0].rstrip('/'), sub_chart_dirs[1].lstrip('/'))
    sub_charts = list_sub_charts(sub_chart_dir)

    output = {'status': '200', 'sub_chart_names': '*'.join(sub_charts)}


    print(json.dumps(output))



