# FILE MANAGED BY ANSIBLE : DO NOT EDIT !!!
# Ansible managed

vcl 4.0;

import directors; #, which provides tools for advanced backend load balancing and health checks.
import std; #which gives access to utility functions like logging, hashing, and string manipulation.

backend localhost {
    .host = "127.0.0.1";
    .port = "81";  # 
    .connect_timeout       = 60s; #Maximum time Varnish waits to establish a TCP connection
    .first_byte_timeout    = 60s; #Maximum time to wait for the first byte of the response from the backend after sending the request.
    .between_bytes_timeout = 60s; #Maximum time allowed between two bytes received from the backend. Prevents the backend from stalling mid-response.
}

#acl purge {
#    "172.17.84.24"; # internal machine  
#    "127.0.0.1"; #  internal machine 
#}


sub vcl_init {
    new myfronts_dir = directors.round_robin(); #This initializes a round-robin backend director named myfronts_dir, and adds a single backend localhost
    myfronts_dir.add_backend(localhost);
}

sub vcl_recv {
    set req.backend_hint = myfronts_dir.backend(); # selecting the backend of myfronts_dir round-robin director for the current request this tells varnish which backend to use.

    ###   START IP management ###
    if (req.http.X-Real-IP) {
        set req.http.X-Origin-Proxy = "Nginx"; #If the request includes an X-Real-IP header (often set by Nginx or another proxy), it assumes a proxy is involved.
    } else {
        set req.http.X-Origin-Proxy = "Local";
    }

    # Normalize the query arguments
    set req.url = std.querysort(req.url);  #Sorts query parameters alphabetically to increase cache hit ratio.
}

