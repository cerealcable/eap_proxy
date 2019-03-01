from behave import *
import subprocess

@given('we launch eap proxy')
def step_impl(context):
    cmd = 'python2 scripts/eap_proxy.py'
    pipes = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    std_out, std_err = pipes.communicate()
    context.std_out = std_out
    context.std_err = std_err
    context.exit_code = pipes.returncode

@then('command help will be shown')
def step_imp(context):
    # Exit code of 2 is for help
    assert context.exit_code == 2, 'EAP Proxy returned exit code %s, expecting 2' % context.exit_code
