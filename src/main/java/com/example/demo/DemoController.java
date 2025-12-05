package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.concurrent.TimeUnit;
import java.util.Random;

@RestController
public class DemoController {

    private final Random random = new Random();

    @GetMapping("/")
    public String home() {
        return "Hello APM! Acesse /fast, /slow ou /error para gerar transações.";
    }

    @GetMapping("/fast")
    public String fastTransaction() {
        return "Transação Rápida OK! (200ms)";
    }

    @GetMapping("/slow")
    public String slowTransaction() throws InterruptedException {
        // Simula uma operação de banco de dados ou serviço externo lenta
        long delay = 1000 + random.nextInt(500); // 1.0s a 1.5s
        TimeUnit.MILLISECONDS.sleep(delay);
        return "Transação Lenta OK! (" + delay + "ms)";
    }

    @GetMapping("/error")
    public String errorTransaction() {
        // Gera uma exceção para o APM capturar
        if (true) {
            throw new RuntimeException("Erro Simulado de Servidor");
        }
        return "Você não deveria ver isso.";
    }
}