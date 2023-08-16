#!/usr/bin/env python3

import sys
import csv
import json
import argparse
from pathlib import Path
import pprint
from collections import OrderedDict

# data2 format
groups2_example = { 
  'source_sourceVersion_target_targetVersion':  {
    'source': 'source url',
    'sourceVersion': 'source version',
    'target': 'target url',
    'targetVersion': 'target version',
    'elements': {
      'codeValue': {
        'code': 'codeValue',
        'display': 'display value',
        'targets': {
          'codeValue': {
            'code': 'code value',
            'display': 'display value'
          }
        }
      }
    }
  }
}


def debug(message):
  print('DEBUG: '+ message)

def warn(message):
  print('WARN: '+ message)

pp = pprint.PrettyPrinter(indent = 2)


parser = argparse.ArgumentParser()
parser.add_argument("--csv", default="mapping-csv-v2.csv", help="Path of CSV V2 input file.")
parser.add_argument("--out", default="cmap.json", help="The ConceptMap output file.")

parser.add_argument("--cm_id", default="map", help="The .id.")
parser.add_argument("--cm_url", default="http://example.com/ConceptMap/map", help="The .url.")
parser.add_argument("--cm_version", default="0.0.0", help="The .version.")
parser.add_argument("--cm_name", default="ExampleConceptMap", help="The .name.")
parser.add_argument("--cm_title", default="Example concept map", help="The .title.")
parser.add_argument("--cm_status", default="draft", help="The .status.")
parser.add_argument("--cm_group_source", default="http://example.com/CodeSystem/source", help="The default .group.source if the CSV doesn't provide it.")
parser.add_argument("--cm_group_source_version", default="0.0.0", help="The default .group.sourceVersion if the CSV doesn't provide it.")
parser.add_argument("--cm_group_target", default="http://example.com/CodeSystem/target", help="The default .group.target if the CSV doesn't provide it.")
parser.add_argument("--cm_group_target_version", default="0.0.0", help="The default .group.targetVersion if the CSV doesn't provide it.")
args= parser.parse_args()


Path(args.out).parent.mkdir(parents=True, exist_ok=True)

cmap = OrderedDict()
cmap["resourceType"] = "ConceptMap"
cmap["id"] = args.cm_id
cmap["url"] = args.cm_url
cmap["version"] = args.cm_version
cmap["name"] = args.cm_name
cmap["title"] = args.cm_title
cmap["status"] = args.cm_status
#cmap["sourceCanonical"] = "http/source/vs"
#cmap["targetCanonical"] = "http://hl7.org/fhir/ValueSet/coverage-type"
cmap['group'] = []

groups= {} # groups indexed by a key of source and target systems and versions

dirty_column_names = False
with open(args.csv, mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)

    for column_name in csv_reader.fieldnames:
      if column_name != column_name.strip():
        warn('Column name has pre/post spaces:'+ column_name)
        dirty_column_names = True

    if dirty_column_names:
      warn("Dirty column names. Exiting")
      sys.exit(1)

    row_count = 0

    for row in csv_reader:
      # for k, v in row.items():
        # print("Key: " + k)
        # print("Value: " + v)
      row_count += 1  # to match actual row number being read
      # https://stackoverflow.com/questions/21045828/convert-dictionary-to-string
      row_string = "ROW:"+ str(row_count) + " " + " & ".join(["{}={}".format(k,v) for k, v in row.items()])
      #print(row_string)

      skip=row.get('_skip', "").strip()
      if skip:
        debug('Skipping row: '+ row_string)
        continue

      source = row.get('.group.source', "").strip() or args.cm_group_source
      source_version = row.get('.group.sourceVersion', "").strip() or args.cm_group_source_version
      target = row.get('.group.target', "").strip() or args.cm_group_target
      target_version = row.get('.group.targetVersion', "").strip() or args.cm_group_target_version
      source_tareget_key = source + " | " + source_version + " | " + target + " | " + target_version
      group = groups.setdefault(source_tareget_key, {'source': source, 'sourceVersion': source_version, 'target': target, 'targetVersion': target_version, 'elements': {} })
      
      source_code = row.get('.group.element.code', "")
      if source_code != source_code.strip():
        warn("Source code surrounded with some space:" + source_code + ', for row: '+ row_string)
        source_code = source_code.strip()
      
      if source_code:
        element = group['elements'].setdefault(source_code, {'code': source_code, 'targets': {}})
      else:
        warn('Missing source code for row, skipping: ' + row_string)
        continue

      source_code_display = row.get('.group.element.display', "")
      if source_code_display != source_code_display.strip():
        warn("Source code display surrounded with some space:"+source_code_display + ', for row: '+ row_string)
        source_code_display = source_code_display.strip()

      if source_code_display:
        element['display'] = source_code_display
      
      target_code = row.get('.group.element.target.code', "")
      if target_code != target_code.strip():
        warn("Target code surrounded with some space:" + target_code + ', for row: '+ row_string)
        target_code = target_code.strip()

      if target_code:
        target = element['targets'].setdefault(target_code, {'code': target_code})
      else:
        warn('Missing target code for row, skipping: ' + row_string)
        continue
      
      target_display = row.get('.group.element.target.display', "")
      if target_display != target_display.strip():
        warn("Target display surrounded with some space:" + target_display + ', for row: '+ row_string)
        target_display = target_display.strip()

      if target_display:
        target['display'] =  target_display

#pp.pprint(groups)

for groupKey, group in groups.items():
  if group['elements']:
    cgroup =   {'source': group['source'],
      'sourceVersion': group['sourceVersion'],
      'target': group['target'],
      'targetVersion': group['targetVersion'],
      'element': []}
    
    for elementKey, element in group['elements'].items():
      celement = {
        'code': element['code'],
        'target': []
      }

      if 'display' in element:
        celement['display'] = element['display']

      for targetKey, target in element['targets'].items():
        ctarget = {
          'code': target['code']
        }
        
        if 'display' in target:
          ctarget['display'] = target['display']

        celement['target'].append(ctarget)

      cgroup['element'].append(celement)

    cmap['group'].append(cgroup)

with open(args.out, "w") as cfile:
  json.dump(cmap, cfile, sort_keys=False, indent=2)