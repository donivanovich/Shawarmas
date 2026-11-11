using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace Shawarmas.Services;

internal static class ApiClient
{
    private static readonly HttpClient Http = new() { Timeout = TimeSpan.FromSeconds(20) };
    private static readonly string BaseUrl = (Environment.GetEnvironmentVariable("API_BASE_URL") ?? "http://127.0.0.1:3001/api/v1").TrimEnd('/');
    private static string? _token;
    public static JsonNode? User { get; private set; }
    public static bool IsAuthenticated => !string.IsNullOrWhiteSpace(_token);

    public static async Task<JsonNode> Login(string email, string password)
    {
        var data = await Send("POST", "/auth/login", new { email, password }, false);
        _token = data["token"]?.GetValue<string>(); User = data["user"]?.DeepClone();
        if (string.IsNullOrWhiteSpace(_token)) throw new InvalidOperationException("The API did not return a session token.");
        return User!;
    }

    public static async Task<JsonNode> Get(string path) => await Send("GET", path, null, true);
    public static async Task<JsonNode> Post(string path, object body) => await Send("POST", path, body, true);
    public static async Task<JsonNode> Patch(string path, object body) => await Send("PATCH", path, body, true);

    public static async Task Logout()
    {
        try { if (IsAuthenticated) await Send("POST", "/auth/logout", null, true); }
        finally { _token = null; User = null; }
    }

    private static async Task<JsonNode> Send(string method, string path, object? body, bool auth)
    {
        using var request = new HttpRequestMessage(new HttpMethod(method), BaseUrl + path);
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        if (auth && !string.IsNullOrWhiteSpace(_token)) request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);
        if (body is not null) request.Content = JsonContent.Create(body);
        using var response = await Http.SendAsync(request);
        var text = await response.Content.ReadAsStringAsync();
        JsonNode? root = null;
        try { root = JsonNode.Parse(text); } catch { }
        if (!response.IsSuccessStatusCode)
        {
            if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized) { _token = null; User = null; }
            throw new HttpRequestException(root?["error"]?["message"]?.GetValue<string>() ?? $"API request failed ({(int)response.StatusCode}).");
        }
        return root?["data"]?.DeepClone() ?? JsonDocument.Parse("{}").RootElement.Deserialize<JsonNode>()!;
    }
}
