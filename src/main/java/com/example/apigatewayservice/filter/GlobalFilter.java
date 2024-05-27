package com.example.apigatewayservice.filter;

import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

@Component
@Slf4j
public class GlobalFilter extends AbstractGatewayFilterFactory<GlobalFilter.Config> {

    public GlobalFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {

        return ((exchange, chain) -> {
            ServerHttpRequest req = exchange.getRequest();
            ServerHttpResponse res = exchange.getResponse();

            if (config.isPreLogger()) {
                log.info("[REQ ID : {}][REQUEST PATH]          -> {}", req.getId(), req.getPath());
                if (!req.getQueryParams().isEmpty()) {
                    log.info("[REQ ID : {}][REQUEST PATH]          -> {}", req.getId(), req.getPath());
                }
            }
            req.getQueryParams();
            return chain.filter(exchange).then(Mono.fromRunnable(() -> {
                if (config.isPostLogger()) {
                    log.info("[REQ ID : {}][RESPONSE STATUS CODE]  -> {}", req.getId(), res.getStatusCode());
                }
            }));
        });
    }

    @Getter
    @Setter
    public static class Config {
        private boolean preLogger;
        private boolean postLogger;
    }

}