import mysql, { type PoolConnection, type RowDataPacket } from 'mysql2/promise';
import { config } from './config.js';

export const pool = mysql.createPool({
  host: config.DB_HOST,
  port: config.DB_PORT,
  database: config.DB_NAME,
  user: config.DB_USER,
  password: config.DB_PASSWORD,
  connectionLimit: config.DB_POOL_SIZE,
  charset: 'utf8mb4',
  decimalNumbers: true,
  enableKeepAlive: true,
  multipleStatements: false
});

type SqlValue = string | number | bigint | boolean | Date | null | Buffer | Uint8Array;

export const rows = async <T extends RowDataPacket>(sql: string, values: SqlValue[] = []): Promise<T[]> => {
  const [result] = await pool.execute<T[]>(sql, values);
  return result;
};

export const transaction = async <T>(operation: (connection: PoolConnection) => Promise<T>): Promise<T> => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const result = await operation(connection);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};
