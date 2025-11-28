import { join } from 'path';

function toBool(v: any, fallback = false) {
  if (v === undefined || v === null || v === '') return fallback;
  const s = String(v).toLowerCase();
  return s === '1' || s === 'true' || s === 'yes' || s === 'on';
}

const base = () => {
  const sslEnabled = toBool(process.env.DB_SSL, false);

  return {
    type: 'postgres' as const,
    host: process.env.DB_HOST,
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT || '5432', 10),
    autoLoadEntities: true,

    // Run migrations automatically when desired
    migrationsRun: toBool(process.env.AUTO_RUN_MIGRATIONS, true),

    // Paths
    entities: [join(__dirname, './../entities/*.entity{.ts,.js}')],
    seeds: [join(__dirname, './../database/seeders/*{.ts,.js}')],
    migrations: [join(__dirname, './../database/migrations/*{.ts,.js}')],
    factories: [join(__dirname, './../factories/*.factory{.ts,.js}')],
    cli: { migrationsDir: join(__dirname, './../database/migrations/') },

    // SSL for RDS. Later harden with CA + rejectUnauthorized: true
    ssl: sslEnabled ? { rejectUnauthorized: false } : false,
  };
};

export default () => ({
  development: {
    ...base(),
    synchronize: false,
    logging: true,
  },

  test: {
    type: 'postgres' as const,
    host: process.env.DB_TEST_HOST,
    username: process.env.DB_TEST_USERNAME,
    password: process.env.DB_TEST_PASSWORD,
    database: process.env.DB_TEST_NAME,
    port: parseInt(process.env.DB_TEST_PORT || '5432', 10),
    autoLoadEntities: true,
    synchronize: true,
    logging: false,
  },

  // Staging config
  staging: {
    ...base(),
    synchronize: false,
    logging: true,
  },

  // Production config
  production: {
    ...base(),
    synchronize: false,
    logging: false,
  },
});
