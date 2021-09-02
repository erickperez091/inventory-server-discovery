package com.example.serverdiscovery;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class ServerDiscoveryApp {
    public static void main(String[] args) {
        SpringApplication.run(ServerDiscoveryApp.class, args);
    }
}
