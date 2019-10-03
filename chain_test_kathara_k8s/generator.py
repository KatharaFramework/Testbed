import ipaddress
import os
import shutil
import argparse

counter = 0
network_shift = 254
base_ip = u"10.0.0.0"

lab_conf = ""

current_id1 = "A"[0]
current_id2 = "A"[0]
current_id3 = "A"[0]
current_id4 = "@"[0]


def get_ip():
    global base_ip, counter

    address = ipaddress.ip_address(base_ip)
    counter += 1
    new_address = address + counter

    if counter % 2 == 0:
        address += network_shift
        base_ip = unicode(str(address))

    return str(new_address) + "/24"


def get_cd_name():
    global current_id1, current_id2, current_id3, current_id4

    ascii_int1 = ord(current_id1)
    ascii_int2 = ord(current_id2)
    ascii_int3 = ord(current_id3)
    ascii_int4 = ord(current_id4)

    if ascii_int4 >= ord('Z'):
        ascii_int3 += 1
        ascii_int4 = ord('A')
    else:
        ascii_int4 += 1

    if ascii_int3 >= ord('Z'):
        ascii_int2 += 1
        ascii_int3 = ord('A')

    if ascii_int2 >= ord('Z'):
        ascii_int1 += 1
        ascii_int2 = ord('A')

    current_id1 = chr(ascii_int1)
    current_id2 = chr(ascii_int2)
    current_id3 = chr(ascii_int3)
    current_id4 = chr(ascii_int4)

    return current_id1 + current_id2 + current_id3 + current_id4


def create_client():
    global lab_conf

    collision_domain = get_cd_name()

    router_ip = get_ip()
    client_ip = get_ip()

    lab_conf += "client[0]=\"%s\"\n\n" % collision_domain

    with open("client.startup", "w") as startup_file:
        startup_file.write("ifconfig net1 %s up\n" % client_ip)
        startup_file.write("route add default gw %s dev net1\n\n" % router_ip.split('/')[0])
        startup_file.write("sysctl net.ipv4.ip_default_ttl=255")
    
    return router_ip, collision_domain


def create_router(num, assigned_ip=None, collision_domain=None):
    global lab_conf

    router_name = "r%d" % num
    collision_domain = collision_domain if collision_domain is not None else get_cd_name()
    lab_conf += "%s[0]=\"%s\"\n" % (router_name, collision_domain)
    collision_domain = get_cd_name()
    lab_conf += "%s[1]=\"%s\"\n\n" % (router_name, collision_domain)
    
    first_ip = assigned_ip if assigned_ip is not None else get_ip()
    second_ip = get_ip()

    with open("%s.startup" % router_name, "w") as startup_file:
        startup_file.write("ifconfig net1 %s up\n" % first_ip)
        startup_file.write("ifconfig net2 %s up\n\n" % second_ip)

        ip_1 = ipaddress.ip_address(unicode(first_ip.split("/")[0])) - 1
        ip_2 = ipaddress.ip_address(unicode(second_ip.split("/")[0])) + 1
        startup_file.write("route add default gw %s dev net2\n" % str(ip_2))
        startup_file.write("route add -net 10.0.0.0/24 gw %s dev net1" % str(ip_1))

    return second_ip, collision_domain


def create_server(ip, collision_domain):
    global lab_conf

    server_ip = get_ip()

    lab_conf += "server[0]=\"%s\"\n\n" % collision_domain

    with open("server.startup", "w") as startup_file:
        startup_file.write("ifconfig net1 %s up\n" % server_ip)
        startup_file.write("route add -net 10.0.0.0/24 gw %s dev net1\n\n" % ip.split('/')[0])
        startup_file.write("/etc/init.d/apache2 start\n\n")
        startup_file.write("sysctl net.ipv4.ip_default_ttl=255")

    os.makedirs("server/var/www/html")
    with open("server/var/www/html/index.html", "w") as index_file:
        index_file.write("<html><body>Hi from the server!</body></html>")


def create_lab(n_routers):
    router_ip, collision_domain = create_client()
    ip, collision_domain = create_router(1, router_ip, collision_domain)

    for i in range(2, n_routers + 1, 1):
        ip, collision_domain = create_router(i, None, collision_domain=collision_domain)

    create_server(ip, collision_domain)

    with open("lab.conf", "w") as lab_file:
        lab_file.write(lab_conf)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create a test Kathara Lab.')
    parser.add_argument(
        "-r", "--routers",
        required=True,
        type=int
    )
    parser.add_argument(
        "-d", "--directory",
        required=False
    )

    args = parser.parse_args()

    lab_path = args.directory if args.directory is not None else "lab/"
    if os.path.isdir(lab_path):
        shutil.rmtree(lab_path)

    os.mkdir(lab_path)
    os.chdir(lab_path)

    create_lab(args.routers)
