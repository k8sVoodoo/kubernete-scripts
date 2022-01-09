import gitlab
import argparse
import datetime
def delete_runners(gl, runners, id, stale_date):
    all_runners = 0
    deleted_runners = 0
    for runner in runners:
        is_stale = False
        contact_date = None
        if stale_date is not None:
            runner_object = gl.runners.get(runner.id)
            if runner_object.contacted_at is not None:
                contacted = datetime.datetime.strptime(runner_object.contacted_at, '%Y-%m-%dT%H:%M:%S.%fZ')
                contact_date = contacted.date()
                if contact_date < stale_date.date():
                    is_stale = True
            else:
                is_stale = True
        all_runners += 1
        try:
            if stale_date is None:
                gl.runners.delete(runner.id, retry_transient_errors=True)
                print("Deleted runner %s:%s" % (runner.id, runner.description))
                deleted_runners += 1
            if contact_date == "Never":
                gl.runners.delete(runner.id, retry_transient_errors=True)
                print("Deleted runner %s:%s" % (runner.id, runner.description))
                deleted_runners += 1
            else:
                if is_stale:
                    gl.runners.delete(runner.id , retry_transient_errors=True)
                    print("Deleted runner %s:%s, contacted at %s" % (runner.id, runner.description, contact_date))
                    deleted_runners += 1
        except Exception as e:
            print("Unable to delete %s:%s Exception: %s" % (runner.id, runner.description, str(e)))
    print("Deleted %s of %s runners found in %s" % (deleted_runners, all_runners, id))

parser = argparse.ArgumentParser(description='Delete group runners')
parser.add_argument('token', help='API token able to read the requested group (Owner)')
parser.add_argument('-g','--group', help='Group ID to delete runners on', action='append')
parser.add_argument('-p','--project', help='Project ID to delete runners on', action='append')
parser.add_argument('--tags', help='Optional list of tags of runners to be deleted (comma separated)')
parser.add_argument('--stale_date', help='Oldest date of last contact. Runners with contacted_at before this date will be deleted. YYYY-MM-DD.')
args = parser.parse_args()
#update gl variable to the correct URL to your gitlab
gl = gitlab.Gitlab("https://<gitlab-url>", private_token=args.token)
if not args.group and not args.project:
    print("ERROR: Need to specify at least one group or project")
    exit(1)
tags = args.tags if args.tags else None
stale_date = None
if args.stale_date:
    print("WARN: Running this with stale_date will result in one additional API call per runner to get their contacted_at date. This may be slow.")
    try:
        stale_date = datetime.datetime.strptime(args.stale_date, '%Y-%m-%d')
        if stale_date > datetime.datetime.now():
            print("ERROR: Stale date may not be in the future")
            exit(1)
    except Exception as e:
        print("ERROR: Not a valid date: %s. Format must be YYYY-MM-DD" % args.stale_date)
        exit(0)
if args.group:
    for group in args.group:
        group = gl.groups.get(group, retry_transient_errors=True)
        runners = group.runners.list(as_list=False, tag_list=tags, type="group_type", retry_transient_errors=True)
        delete_runners(gl, runners, group.id, stale_date)
if args.project:
    for project in args.project:
        project = gl.projects.get(project, retry_transient_errors=True)
        runners = project.runners.list(as_list=False, tag_list=tags, type="project_type", retry_transient_errors=True)
        delete_runners(gl, runners, project.id, stale_date)