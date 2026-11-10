using System.Data;
using MySql.Data.MySqlClient;

namespace Shawarmas.Services;

public sealed class ServiceDatabase
{
    private readonly string _connectionString;

    public ServiceDatabase()
    {
        var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "127.0.0.1";
        var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "3307";
        var database = Environment.GetEnvironmentVariable("DB_NAME") ?? "shawarmas";
        var user = Environment.GetEnvironmentVariable("DB_USER") ?? "shawarmas_app";
        var password = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "1234";
        _connectionString = $"Server={host};Port={port};Database={database};Uid={user};Password={password};SslMode=Preferred;";
    }

    public DataTable ExecuteQuery(string sql, params MySqlParameter[] parameters)
    {
        using var conn = new MySqlConnection(_connectionString);
        using var cmd = new MySqlCommand(sql, conn);
        cmd.Parameters.AddRange(parameters);
        using var adapter = new MySqlDataAdapter(cmd);
        var table = new DataTable();
        conn.Open();
        adapter.Fill(table);
        return table;
    }

    public int ExecuteCommand(string sql, params MySqlParameter[] parameters)
    {
        using var conn = new MySqlConnection(_connectionString);
        using var cmd = new MySqlCommand(sql, conn);
        cmd.Parameters.AddRange(parameters);
        conn.Open();
        return cmd.ExecuteNonQuery();
    }
}
