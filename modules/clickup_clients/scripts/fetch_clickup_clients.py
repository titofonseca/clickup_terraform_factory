#!/usr/bin/env python3
"""
Minimal ClickUp fetcher for Terraform external data source.
Input via query: api_token, space_id, list_id.
Output JSON with structure: {"clients": [{"name": str, "env": str, "region": str}]}

Rules:
- Only tasks with status containing "sync" (case-insensitive) are active.
- Task name is the client name; remove trailing "_config" if present.
- Read custom fields "env" and "region" (case-insensitive match on field name).
"""

import json
import sys
import requests


def extract_client_name(task_name: str) -> str:
    if task_name.endswith("_config"):
        return task_name[:-7]
    return task_name


def main():
    raw = sys.stdin.read()
    params = json.loads(raw or "{}")

    api_token = params.get("api_token")
    space_id = params.get("space_id")
    list_id = params.get("list_id")

    if not api_token or not space_id or not list_id:
        print(json.dumps({"clients": []}))
        return

    headers = {"Authorization": api_token}
    base_url = "https://api.clickup.com/api/v2"

    # Get list custom fields (id -> name)
    try:
        fields_resp = requests.get(f"{base_url}/list/{list_id}/field", headers=headers)
        fields_resp.raise_for_status()
        fields = fields_resp.json().get("fields", [])
        field_map = {f["id"]: f.get("name", "").strip() for f in fields}
    except Exception:
        field_map = {}

    # Get tasks for list
    try:
        tasks_resp = requests.get(
            f"{base_url}/list/{list_id}/task",
            headers=headers,
            params={"include_closed": "true"},
        )
        tasks_resp.raise_for_status()
        tasks = tasks_resp.json().get("tasks", [])
    except Exception:
        print(json.dumps({"clients": []}))
        return

    clients = []
    for task in tasks:
        task_status = (task.get("status", {}).get("status") or "").lower()
        if "sync" not in task_status:
            continue

        name = extract_client_name(task.get("name") or "")

        # fetch task details for custom fields
        env_val = ""
        region_val = ""
        try:
            task_id = task.get("id")
            det = requests.get(f"{base_url}/task/{task_id}", headers=headers)
            det.raise_for_status()
            custom_fields = det.json().get("custom_fields", [])
            for f in custom_fields:
                field_id = f.get("id")
                field_name = (field_map.get(field_id) or "").strip().lower()
                raw_val = f.get("value")
                if raw_val is None:
                    continue
                val = None
                if isinstance(raw_val, dict):
                    if "value" in raw_val:
                        val = raw_val.get("value")
                    elif "options" in raw_val and raw_val.get("options"):
                        val = raw_val["options"][0].get("name")
                if val is None:
                    val = raw_val
                if field_name == "env":
                    env_val = str(val)
                if field_name == "region":
                    region_val = str(val)
        except Exception:
            pass

        clients.append({"name": name, "env": env_val, "region": region_val})

    # Terraform external data requires all values to be strings
    print(json.dumps({"clients": json.dumps(clients)}))


if __name__ == "__main__":
    main()


