using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace Wpf10_Shawarmas.Services
{
    class ServiceDatabase
    {
        public ServiceDatabase()
        {
            _connectionString = "Server=localhost;Port=3309;Database=shawarmas;Uid=root;Pwd=1234;";
        }

        private readonly string _connectionString;

        public DataTable ExecuteQuery(string sql)
        {
            using var conn = new MySqlConnection(_connectionString);
            conn.Open();

            using var cmd = new MySqlCommand(sql, conn);
            using var adapter = new MySqlDataAdapter(cmd);
            var dt = new DataTable();
            adapter.Fill(dt);

            return dt;
        }

        public void ExecuteCommand(string sql)
        {
            using var conn = new MySqlConnection(_connectionString);
            conn.Open();
            using var cmd = new MySqlCommand(sql, conn);
            cmd.ExecuteNonQuery();
        }
    }
}