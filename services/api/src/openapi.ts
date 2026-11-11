const openapi = {
  openapi: '3.1.0',
  info: { title: 'Shawarmas API', version: '1.0.0', description: 'Central data and business API for the Shawarmas PHP, Java and WPF applications.' },
  servers: [{ url: '/api/v1' }],
  tags: [{ name: 'Authentication' }, { name: 'Catalog' }, { name: 'Orders' }, { name: 'Administration' }],
  components: {
    securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'Opaque session token' } },
    schemas: {
      Error: { type: 'object', properties: { error: { type: 'object', required: ['code', 'message'], properties: { code: { type: 'string' }, message: { type: 'string' }, requestId: { type: 'string' } } } } },
      Product: { type: 'object', properties: { id_producto: { type: 'integer' }, marca: { type: 'string' }, modelo: { type: 'string' }, precio: { type: 'number' }, imagen: { type: ['string', 'null'] }, descripcion: { type: ['string', 'null'] }, variants: { type: 'array', items: { type: 'object' } } } }
    }
  },
  paths: {
    '/auth/register': { post: { tags: ['Authentication'], summary: 'Register a customer', responses: { '201': { description: 'Customer created and signed in' }, '400': { description: 'Invalid input' }, '409': { description: 'Email already exists' } } } },
    '/auth/login': { post: { tags: ['Authentication'], summary: 'Sign in a customer or employee', responses: { '200': { description: 'Session created' }, '401': { description: 'Invalid credentials' } } } },
    '/auth/me': { get: { tags: ['Authentication'], security: [{ bearerAuth: [] }], summary: 'Current account', responses: { '200': { description: 'Account profile' } } }, patch: { tags: ['Authentication'], security: [{ bearerAuth: [] }], summary: 'Update current profile', responses: { '200': { description: 'Profile updated' } } } },
    '/auth/refresh': { post: { tags: ['Authentication'], security: [{ bearerAuth: [] }], summary: 'Rotate and renew session token', responses: { '200': { description: 'New bearer token' } } } },
    '/auth/logout': { post: { tags: ['Authentication'], security: [{ bearerAuth: [] }], summary: 'Revoke current session', responses: { '204': { description: 'Session revoked' } } } },
    '/products': { get: { tags: ['Catalog'], summary: 'Search and paginate catalog', responses: { '200': { description: 'Product page' } } }, post: { tags: ['Catalog'], security: [{ bearerAuth: [] }], summary: 'Create product and variants', responses: { '201': { description: 'Product created' } } } },
    '/products/{id}': { get: { tags: ['Catalog'], summary: 'Product details and variants', parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }], responses: { '200': { description: 'Product found' }, '404': { description: 'Product not found' } } }, patch: { tags: ['Catalog'], security: [{ bearerAuth: [] }], summary: 'Update product fields', responses: { '200': { description: 'Product updated' } } } },
    '/categories': { get: { tags: ['Catalog'], summary: 'List categories', responses: { '200': { description: 'Categories' } } } },
    '/colors': { get: { tags: ['Catalog'], summary: 'List colors and swatch paths', responses: { '200': { description: 'Colors' } } } },
    '/sizes': { get: { tags: ['Catalog'], summary: 'List sizes', responses: { '200': { description: 'Sizes' } } } },
    '/cart/quote': { post: { tags: ['Orders'], security: [{ bearerAuth: [] }], summary: 'Validate cart and calculate server totals', responses: { '200': { description: 'Validated quote' }, '409': { description: 'Insufficient stock' } } } },
    '/orders': { get: { tags: ['Orders'], security: [{ bearerAuth: [] }], summary: 'List own orders or staff order list', responses: { '200': { description: 'Orders' } } }, post: { tags: ['Orders'], security: [{ bearerAuth: [] }], summary: 'Create order and reserve stock transactionally', responses: { '201': { description: 'Order created' }, '409': { description: 'Stock conflict' } } } },
    '/orders/{id}': { get: { tags: ['Orders'], security: [{ bearerAuth: [] }], summary: 'Get order details; customers can access only their own', responses: { '200': { description: 'Order detail' }, '404': { description: 'Order not found' } } } },
    '/orders/{id}/status': { patch: { tags: ['Orders'], security: [{ bearerAuth: [] }], summary: 'Update delivery status', responses: { '200': { description: 'Status updated' } } } },
    '/admin/customers': { get: { tags: ['Administration'], security: [{ bearerAuth: [] }], summary: 'List customers', responses: { '200': { description: 'Customer page' } } }, post: { tags: ['Administration'], security: [{ bearerAuth: [] }], summary: 'Create customer', responses: { '201': { description: 'Customer created' } } } },
    '/admin/employees': { get: { tags: ['Administration'], security: [{ bearerAuth: [] }], summary: 'List employees without password hashes', responses: { '200': { description: 'Employees' } } }, post: { tags: ['Administration'], security: [{ bearerAuth: [] }], summary: 'Create employee', responses: { '201': { description: 'Employee created' } } } },
    '/admin/stores': { get: { tags: ['Administration'], security: [{ bearerAuth: [] }], summary: 'List stores', responses: { '200': { description: 'Stores' } } }, post: { tags: ['Administration'], security: [{ bearerAuth: [] }], summary: 'Create store', responses: { '201': { description: 'Store created' } } } }
  }
};

export default openapi;
