package com.shawarmas;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.ArrayNode;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

/** Shared HTTP-only client for the Shawarmas API. Session tokens remain in memory. */
public final class ApiClient {
    private static final ApiClient INSTANCE = new ApiClient();
    private static final ObjectMapper JSON = new ObjectMapper();
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final String baseUrl = System.getenv().getOrDefault("API_BASE_URL", "http://127.0.0.1:3001/api/v1").replaceAll("/+$", "");
    private volatile String token;
    private volatile long expiresAt;

    private ApiClient() { }
    public static ApiClient getInstance() { return INSTANCE; }

    public JsonNode login(String email, String password) throws IOException, InterruptedException {
        try {
            JsonNode session = request("POST", "/auth/login", object("email", email, "password", password), false, false);
            setSession(session);
            return session.path("user");
        } catch (IOException | InterruptedException | RuntimeException error) {
            logoutLocal();
            throw error;
        }
    }

    public JsonNode registerCustomer(String name, String surname, String secondSurname, String email, String password) throws IOException, InterruptedException {
        try {
            JsonNode session = request("POST", "/auth/register", object("nombre", name, "apellido1", surname,
                "apellido2", secondSurname.isBlank() ? null : secondSurname, "email", email, "password", password), false, false);
            setSession(session);
            return session.path("user");
        } catch (IOException | InterruptedException | RuntimeException error) {
            logoutLocal();
            throw error;
        }
    }

    public JsonNode get(String path) throws IOException, InterruptedException { return request("GET", path, null, true, true); }
    public JsonNode post(String path, JsonNode payload) throws IOException, InterruptedException { return request("POST", path, payload, true, true); }
    public JsonNode patch(String path, JsonNode payload) throws IOException, InterruptedException { return request("PATCH", path, payload, true, true); }
    public JsonNode put(String path, JsonNode payload) throws IOException, InterruptedException { return request("PUT", path, payload, true, true); }

    public ObjectNode object(Object... entries) {
        ObjectNode node = JSON.createObjectNode();
        for (int i = 0; i < entries.length; i += 2) {
            String key = (String) entries[i];
            Object value = entries[i + 1];
            if (value == null) node.putNull(key);
            else if (value instanceof String s) node.put(key, s);
            else if (value instanceof Integer number) node.put(key, number);
            else if (value instanceof Long number) node.put(key, number);
            else if (value instanceof Boolean bool) node.put(key, bool);
            else if (value instanceof Double number) node.put(key, number);
            else node.set(key, JSON.valueToTree(value));
        }
        return node;
    }
    public ArrayNode array() { return JSON.createArrayNode(); }

    public void logout() {
        try {
            if (token != null) request("POST", "/auth/logout", null, true, false);
        } catch (Exception ignored) {
            // Clear local credentials even when the API cannot be reached.
        } finally {
            logoutLocal();
        }
    }

    private JsonNode request(String method, String path, JsonNode payload, boolean authenticated, boolean allowRenew) throws IOException, InterruptedException {
        if (authenticated && (token == null || token.isBlank())) throw new IOException("Sign in to the Shawarmas API first.");
        if (authenticated && allowRenew && expiresAt > 0 && expiresAt - System.currentTimeMillis() < 300000) renew();
        HttpRequest.Builder builder = HttpRequest.newBuilder(URI.create(baseUrl + (path.startsWith("/") ? path : "/" + path)))
            .timeout(Duration.ofSeconds(15)).header("Accept", "application/json");
        if (authenticated) builder.header("Authorization", "Bearer " + token);
        if (payload != null) builder.header("Content-Type", "application/json");
        HttpRequest.BodyPublisher body = payload == null ? HttpRequest.BodyPublishers.noBody() : HttpRequest.BodyPublishers.ofString(JSON.writeValueAsString(payload));
        HttpResponse<String> response = http.send(builder.method(method, body).build(), HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() == 401 && authenticated) {
            token = null;
            expiresAt = 0;
        }
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            String message = "The Shawarmas API request failed (HTTP " + response.statusCode() + ").";
            try { message = JSON.readTree(response.body()).path("error").path("message").asText(message); } catch (Exception ignored) { }
            throw new IOException(message);
        }
        if (response.statusCode() == 204 || response.body().isBlank()) return JSON.nullNode();
        JsonNode root = JSON.readTree(response.body());
        return root.path("data");
    }

    private synchronized void renew() throws IOException, InterruptedException {
        if (token == null) throw new IOException("Your API session has expired. Sign in again.");
        if (expiresAt - System.currentTimeMillis() >= 300000) return;
        JsonNode refreshed = request("POST", "/auth/refresh", null, true, false);
        setSession(refreshed);
    }

    private void logoutLocal() { token = null; expiresAt = 0; }

    private void setSession(JsonNode session) {
        token = session.path("token").asText();
        expiresAt = System.currentTimeMillis() + session.path("expiresIn").asLong(0) * 1000;
        if (token.isBlank()) throw new IllegalStateException("The API did not return a session token.");
    }
}
