using System.IO;
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
    private static readonly SemaphoreSlim RefreshGate = new(1, 1);
    private static string? _token;
    private static DateTimeOffset _expiresAt;
    public static JsonNode? User { get; private set; }
    public static bool IsAuthenticated => !string.IsNullOrWhiteSpace(_token);

    public static async Task<JsonNode> Login(string email, string password)
    {
        var data = await Send("POST", "/auth/login", new { email, password }, false);
        _token = data["token"]?.GetValue<string>(); User = data["user"]?.DeepClone();
        _expiresAt = DateTimeOffset.UtcNow.AddSeconds(data["expiresIn"]?.GetValue<long>() ?? 0);
        if (string.IsNullOrWhiteSpace(_token)) throw new InvalidOperationException("The API did not return a session token.");
        return User!;
    }

    public static async Task<JsonNode> Get(string path) => await Send("GET", path, null, true);
    public static async Task<JsonNode> Post(string path, object body) => await Send("POST", path, body, true);
    public static async Task<JsonNode> Patch(string path, object body) => await Send("PATCH", path, body, true);

    public static async Task<JsonNode> UploadImage(string filePath)
    {
        if (!File.Exists(filePath)) throw new FileNotFoundException("Select an image file that still exists.", filePath);
        using var form = new MultipartFormDataContent();
        await using var stream = File.OpenRead(filePath);
        using var file = new StreamContent(stream);
        var extension = Path.GetExtension(filePath).ToLowerInvariant();
        var mediaType = extension switch { ".png" => "image/png", ".jpg" or ".jpeg" => "image/jpeg", ".webp" => "image/webp", _ => "application/octet-stream" };
        file.Headers.ContentType = MediaTypeHeaderValue.Parse(mediaType);
        form.Add(file, "image", Path.GetFileName(filePath));
        using var request = new HttpRequestMessage(HttpMethod.Post, BaseUrl + "/admin/images/products") { Content = form };
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        if (!IsAuthenticated) throw new HttpRequestException("Sign in before uploading a product image.");
        await RefreshIfNeeded();
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _token);
        using var response = await Http.SendAsync(request);
        var text = await response.Content.ReadAsStringAsync();
        var root = JsonNode.Parse(text);
        if (!response.IsSuccessStatusCode)
        {
            if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized) ClearSession();
            throw new HttpRequestException(root?["error"]?["message"]?.GetValue<string>() ?? $"Image upload failed ({(int)response.StatusCode}).");
        }
        return root?["data"]?.DeepClone() ?? throw new HttpRequestException("The API returned an invalid image response.");
    }

    public static async Task Logout()
    {
        try { if (IsAuthenticated) await Send("POST", "/auth/logout", null, true); }
        finally { ClearSession(); }
    }

    private static async Task<JsonNode> Send(string method, string path, object? body, bool auth)
    {
        if (auth && path != "/auth/refresh") await RefreshIfNeeded();
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
            if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized) ClearSession();
            throw new HttpRequestException(root?["error"]?["message"]?.GetValue<string>() ?? $"API request failed ({(int)response.StatusCode}).");
        }
        return root?["data"]?.DeepClone() ?? JsonDocument.Parse("{}").RootElement.Deserialize<JsonNode>()!;
    }

    private static async Task RefreshIfNeeded()
    {
        if (!IsAuthenticated) throw new HttpRequestException("Your session has expired. Sign in again.");
        if (_expiresAt - DateTimeOffset.UtcNow > TimeSpan.FromMinutes(5)) return;
        await RefreshGate.WaitAsync();
        try
        {
            if (!IsAuthenticated) throw new HttpRequestException("Your session has expired. Sign in again.");
            if (_expiresAt - DateTimeOffset.UtcNow > TimeSpan.FromMinutes(5)) return;
            var data = await Send("POST", "/auth/refresh", null, true);
            _token = data["token"]?.GetValue<string>();
            _expiresAt = DateTimeOffset.UtcNow.AddSeconds(data["expiresIn"]?.GetValue<long>() ?? 0);
            if (string.IsNullOrWhiteSpace(_token)) { ClearSession(); throw new HttpRequestException("Your session could not be renewed. Sign in again."); }
        }
        catch { ClearSession(); throw; }
        finally { RefreshGate.Release(); }
    }

    private static void ClearSession() { _token = null; _expiresAt = DateTimeOffset.MinValue; User = null; }
}
