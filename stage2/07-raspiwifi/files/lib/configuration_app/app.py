from flask import Flask, render_template, request, redirect
import subprocess
import os
import sys
import time
import yaml
from threading import Thread
import fileinput

app = Flask(__name__)
app.debug = True

is_test = False
title_vendor_name = ''
footer_vendor_name = ''
footer_version_nr = ''
footer_year = ''

@app.route('/')
def index():
    if is_test == True:
        wifi_ap_array = ['hello','abcd']
    else:
        wifi_ap_array = scan_wifi_networks()
    config_hash = config_file_hash()

    return render_template('app.html', wifi_ap_array = wifi_ap_array, config_hash = config_hash, footer_vendor_name = footer_vendor_name, footer_version_nr = footer_version_nr, footer_year = footer_year, title_vendor_name = title_vendor_name)

@app.route("/<path:path>")
def catch_all(path):
    return redirect("http://10.0.0.1/", code=302)

@app.route('/manual_ssid_entry')
def manual_ssid_entry():
    return render_template('manual_ssid_entry.html', footer_vendor_name = footer_vendor_name, footer_version_nr = footer_version_nr, footer_year = footer_year, title_vendor_name = title_vendor_name)

@app.route('/wpa_settings')
def wpa_settings():
    config_hash = config_file_hash()
    return render_template('wpa_settings.html', wpa_enabled = config_hash['wpa_enabled'], wpa_key = config_hash['wpa_key'], footer_vendor_name = footer_vendor_name, footer_version_nr = footer_version_nr, footer_year = footer_year, title_vendor_name = title_vendor_name)


@app.route('/save_credentials', methods = ['GET', 'POST'])
def save_credentials():
    ssid = request.form['ssid']
    wifi_key = request.form['wifi_key']

    if is_test == False:
        create_wpa_supplicant(ssid, wifi_key)
    
    # Call set_ap_client_mode() in a thread otherwise the reboot will prevent
    # the response from getting to the browser
    def sleep_and_start_ap():
        time.sleep(2)
        if is_test == False:
            set_ap_client_mode()
    t = Thread(target=sleep_and_start_ap)
    t.start()

    return render_template('save_credentials.html', ssid = ssid, footer_vendor_name = footer_vendor_name, footer_version_nr = footer_version_nr, footer_year = footer_year, title_vendor_name = title_vendor_name)


@app.route('/save_wpa_credentials', methods = ['GET', 'POST'])
def save_wpa_credentials():
    config_hash = config_file_hash()
    wpa_enabled = request.form.get('wpa_enabled')
    wpa_key = request.form['wpa_key']

    if is_test == False:
        if str(wpa_enabled) == '1':
            update_wpa(1, wpa_key)
        else:
            update_wpa(0, wpa_key)

    def sleep_and_reboot_for_wpa():
        time.sleep(2)
        os.system('reboot')

    t = Thread(target=sleep_and_reboot_for_wpa)
    t.start()

    config_hash = config_file_hash()
    return render_template('save_wpa_credentials.html', wpa_enabled = config_hash['wpa_enabled'], wpa_key = config_hash['wpa_key'], footer_vendor_name = footer_vendor_name, footer_version_nr = footer_version_nr, footer_year = footer_year, title_vendor_name = title_vendor_name)




######## FUNCTIONS ##########

def scan_wifi_networks():
    iwlist_raw = subprocess.Popen(['iwlist', 'scan'], stdout=subprocess.PIPE)
    ap_list, err = iwlist_raw.communicate()
    ap_array = []

    for line in ap_list.decode('utf-8').rsplit('\n'):
        if 'ESSID' in line:
            ap_ssid = line[27:-1]
            if ap_ssid != '':
                ap_array.append(ap_ssid)

    return ap_array

def create_wpa_supplicant(ssid, wifi_key):
    temp_conf_file = open('wpa_supplicant.conf.tmp', 'w')

    temp_conf_file.write('ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev\n')
    temp_conf_file.write('update_config=1\n')
    temp_conf_file.write('\n')
    temp_conf_file.write('network={\n')
    temp_conf_file.write('	ssid="' + ssid + '"\n')

    if wifi_key == '':
        temp_conf_file.write('	key_mgmt=NONE\n')
    else:
        temp_conf_file.write('	psk="' + wifi_key + '"\n')

    temp_conf_file.write('	}')

    temp_conf_file.close

    os.system('mv wpa_supplicant.conf.tmp /etc/wpa_supplicant/wpa_supplicant.conf')

def set_ap_client_mode():
    os.system('rm -f /etc/raspiwifi/host_mode')
    os.system('rm /etc/cron.raspiwifi/aphost_bootstrapper')
    os.system('cp /usr/lib/raspiwifi/reset_device/static_files/apclient_bootstrapper /etc/cron.raspiwifi/')
    os.system('chmod +x /etc/cron.raspiwifi/apclient_bootstrapper')
    os.system('mv /etc/dnsmasq.conf.original /etc/dnsmasq.conf')
    os.system('mv /etc/dhcpcd.conf.original /etc/dhcpcd.conf')
    # TODO: Configure IPTABLES and DNSMASQ for client mode
    os.system('reboot')

def update_wpa(wpa_enabled, wpa_key):
    with fileinput.FileInput('/etc/raspiwifi/raspiwifi.conf', inplace=True) as raspiwifi_conf:
        for line in raspiwifi_conf:
            if 'wpa_enabled=' in line:
                line_array = line.split('=')
                line_array[1] = wpa_enabled
                print(line_array[0] + '=' + str(line_array[1]))

            if 'wpa_key=' in line:
                line_array = line.split('=')
                line_array[1] = wpa_key
                print(line_array[0] + '=' + line_array[1])

            if 'wpa_enabled=' not in line and 'wpa_key=' not in line:
                print(line, end='')


def config_file_hash():
    config_file_path = '/etc/raspiwifi/raspiwifi.conf'
    if is_test == True:
        config_file_path = 'raspiwifi.conf'
    config_file = open(config_file_path)
    config_hash = {}

    for line in config_file:
        line_key = line.split("=")[0]
        line_value = line.split("=")[1].rstrip()
        config_hash[line_key] = line_value

    return config_hash


if __name__ == '__main__':
    if os.path.exists('config.yaml'):
        file = open('config.yaml', 'r')
        cfg = yaml.load(file, Loader=yaml.FullLoader)

        footer_vendor_name = cfg['web']['footer']['vendor_name']
        footer_version_nr = cfg['web']['footer']['version_nr']
        footer_year = cfg['web']['footer']['year']
        title_vendor_name = cfg['web']['title']
    else:
        footer_vendor_name = 'Fancy Startup'
        footer_version_nr = '1.0'
        footer_year = '2020'
        title_vendor_name = footer_vendor_name
    
    print(footer_vendor_name, footer_year, footer_version_nr)

    if len(sys.argv) > 1:
        is_test_string = sys.argv[1]
        if is_test_string == '--test':
            print('Staring app in test mode ...')
            is_test = True
    config_hash = config_file_hash()

    if config_hash['ssl_enabled'] == "1":
        app.run(host = '0.0.0.0', port = int(config_hash['server_port']), ssl_context='adhoc')
    else:
        app.run(host = '0.0.0.0', port = int(config_hash['server_port']))
