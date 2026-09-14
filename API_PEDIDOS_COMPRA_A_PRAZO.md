# 🧾 API Pedidos de Compra a Prazo - Documentação

Funcionalidade **Compra a Prestação** (*Installment Purchase Request*). O marketplace é a
fonte de dados autoritativa: o website institucional consome esta API e não acede à base de
dados do marketplace.

## 🔐 Autenticação e identificação da origem

| Cenário | Cabeçalhos | `source` gravado |
| ------- | ---------- | ---------------- |
| Aplicação/cliente do marketplace autenticado | `Authorization: Bearer {token}` (guard `api`) | `marketplace` |
| Visitante do marketplace (convidado) | — | `marketplace` |
| Website institucional | `X-Website-Api-Key: {PURCHASE_REQUEST_WEBSITE_API_KEY}` | `website` |

O campo `source` **nunca** é aceite do cliente: é sempre resolvido no backend a partir da
chave do website (`config/purchase_request.php`). Um valor `source` enviado no payload é
ignorado.

Variáveis de ambiente necessárias:

```
PURCHASE_REQUEST_WEBSITE_API_KEY=chave-partilhada-com-o-website
PURCHASE_REQUEST_NOTIFICATION_EMAIL=   # opcional, por omissão usa o company_email
```

## 🎯 Endpoints

### 1. **Lojas disponíveis e opções de parcelamento**

```http
GET /api/v1/purchase-requests/stores
```

**Autenticação:** pública.

**Resposta de Sucesso (200):**
```json
{
    "total_size": 2,
    "stores": [
        { "id": 15, "name": "Loja Central" },
        { "id": 21, "name": "Loja Matola" }
    ],
    "installment_options": [3, 6, 12, 18, 24]
}
```

Apenas lojas de vendedores aprovados e não temporariamente fechadas são devolvidas.
As opções de parcelamento reutilizam os períodos activos da configuração
`pagamento_a_prazo`; se nenhum estiver activo, usa-se `config('purchase_request.installment_options')`.

### 2. **Criar pedido de compra a prazo**

```http
POST /api/v1/purchase-requests
```

**Autenticação:** pública (opcionalmente `Authorization: Bearer {token}` do cliente).
**Rate limit:** 10 pedidos por minuto por IP.

**Body (JSON) - qualquer loja disponível:**
```json
{
    "name": "Nome do Cliente",
    "email": "cliente@exemplo.com",
    "phone": "+258840000000",
    "product_description": "Frigorífico de duas portas com congelador",
    "installments": 6,
    "store_type": "any_store",
    "store_id": null
}
```

**Body (JSON) - loja específica:**
```json
{
    "name": "Nome do Cliente",
    "email": "cliente@exemplo.com",
    "phone": "+258840000000",
    "product_description": "Frigorífico de duas portas com congelador",
    "installments": 6,
    "store_type": "specific_store",
    "store_id": 15
}
```

**Regras de validação:**

| Campo | Regras |
| ----- | ------ |
| `name` | obrigatório se não houver cliente autenticado, string, máx. 100 |
| `email` | obrigatório se não houver cliente autenticado, email válido, máx. 100 |
| `phone` | obrigatório se não houver cliente autenticado, entre 4 e 20 dígitos |
| `product_description` | obrigatório, string, entre 10 e 2000 caracteres |
| `installments` | obrigatório, inteiro, dentro das opções activas de parcelamento |
| `store_type` | obrigatório, `any_store` ou `specific_store` |
| `store_id` | obrigatório quando `store_type=specific_store`, tem de existir e pertencer a uma loja activa |

Quando existe cliente autenticado (guard `api`), os dados de nome, email e telefone são
retirados da conta e os campos equivalentes do payload são ignorados.

**Resposta de Sucesso (200):**
```json
{
    "message": "Your installment purchase request has been sent successfully",
    "reference": "CB-REQ-20260827-A1B2",
    "data": {
        "reference": "CB-REQ-20260827-A1B2",
        "name": "Nome do Cliente",
        "email": "cliente@exemplo.com",
        "phone": "+258840000000",
        "product_description": "Frigorífico de duas portas com congelador",
        "installments": 6,
        "store_preference": "specific_store",
        "store": { "id": 15, "name": "Loja Central" },
        "source": "website",
        "status": "pending",
        "created_at": "2026-08-27T10:15:00.000000Z"
    }
}
```

**Erro de validação (422):**
```json
{
    "errors": [
        { "code": "product_description", "message": "Product description is required" },
        { "code": "store_id", "message": "The selected store is not available" }
    ]
}
```

**Erro de servidor (500):**
```json
{
    "errors": [
        { "code": "purchase_request", "message": "Your request could not be processed, please try again" }
    ]
}
```

### 3. **Consultar pedido**

```http
GET /api/v1/purchase-requests/{reference}
```

**Autenticação:** cliente autenticado (`Authorization: Bearer {token}`) ou website
(`X-Website-Api-Key`). O identificador público é a referência (`CB-REQ-...`); o ID interno
não é exposto.

- Cliente autenticado: só acede aos pedidos da própria conta.
- Website: acede pela referência.

**Resposta de Sucesso (200):**
```json
{
    "data": {
        "reference": "CB-REQ-20260827-A1B2",
        "installments": 6,
        "store_preference": "any_store",
        "store": null,
        "source": "website",
        "status": "reviewing",
        "created_at": "2026-08-27T10:15:00.000000Z"
    }
}
```

**Sem credenciais (401):**
```json
{ "message": "Unauthenticated" }
```

**Referência inexistente (404):**
```json
{ "message": "Purchase request not found" }
```

### 4. **API do vendedor (aplicação do vendedor)**

```http
GET /api/v3/seller/purchase-request/list?status=pending&limit=25
GET /api/v3/seller/purchase-request/single-item/{reference}
```

**Autenticação:** `Authorization: Bearer {auth_token}` do vendedor (middleware
`seller_api_auth`, igual às restantes rotas `v3/seller`).

A listagem devolve **apenas** os pedidos atribuídos à loja do vendedor autenticado. Pedidos
sem loja específica (`store_id = null`) e pedidos de outras lojas não são devolvidos.
Consultar uma referência de outra loja devolve `404`.

**Resposta de Sucesso (200):**
```json
{
    "total_size": 1,
    "limit": 25,
    "data": [
        {
            "reference": "CB-REQ-20260827-A1B2",
            "name": "Nome do Cliente",
            "installments": 6,
            "store_preference": "specific_store",
            "store": { "id": 15, "name": "Loja Central" },
            "status": "pending"
        }
    ]
}
```

## 🛠️ Gestão administrativa

O marketplace não possui API com token para administradores; a gestão de pedidos usa o
painel de administração existente (sessão + `module:order_management`), seguindo a mesma
convenção das restantes áreas administrativas:

| Método | Rota | Objectivo |
| ------ | ---- | --------- |
| GET | `admin/purchase-request/list` | Listar todos os pedidos, com pesquisa e filtros (estado, origem, preferência de loja, loja) |
| GET | `admin/purchase-request/view/{id}` | Detalhe do pedido |
| POST | `admin/purchase-request/update/{id}` | Actualizar estado e notas internas |

O administrador global vê **todos** os pedidos, incluindo os atribuídos a lojas específicas.

Painel do vendedor (sessão, middleware `seller`):

| Método | Rota | Objectivo |
| ------ | ---- | --------- |
| GET | `vendor/purchase-request/list` | Pedidos atribuídos à própria loja |
| GET | `vendor/purchase-request/view/{id}` | Detalhe de um pedido da própria loja |

## 🏷️ Referência do pedido

Formato: `CB-REQ-AAAAMMDD-XXXX` (ex.: `CB-REQ-20260827-A1B2`), único, gerado no servidor e
devolvido pela API. É usado no painel, nas notificações por email e na comunicação com o
cliente.

## 🔁 Estados

```
pending → reviewing → approved | rejected → completed
```

## 📧 Notificações

Ao criar um pedido é despachado o evento `PurchaseRequestPlacedEvent`. O listener envia,
através da fila existente (`SendEmailJob`):

1. Email para o endereço administrativo (`PURCHASE_REQUEST_NOTIFICATION_EMAIL` ou
   `company_email` das configurações de negócio).
2. Email para o vendedor da loja selecionada, quando `store_id` está definido.
3. Email de confirmação para o cliente, com a referência do pedido.

Falhas de envio são registadas no log com a referência do pedido, sem dados sensíveis.

## 🧪 Testes

O histórico de migrações deste projecto não pode ser reproduzido a partir de uma base de
dados vazia (existem migrações de alteração anteriores à criação das respectivas tabelas),
por isso os testes desta funcionalidade correm sobre uma base de dados de testes já
preparada e cada teste é envolvido numa transação que é revertida no fim.

Preparar a base de dados de testes (uma única vez):

```bash
mysql -uroot -e "create database cobest_marketplace_test"
mysqldump -uroot --no-data cobest_marketplace_upgrade | mysql -uroot cobest_marketplace_test
DB_DATABASE=cobest_marketplace_test php artisan migrate \
    --path=database/migrations/2026_08_27_100000_create_purchase_requests_table.php
```

Correr a suite:

```bash
php vendor/bin/phpunit -c phpunit.feature.xml
```

Qualquer valor de `phpunit.feature.xml` pode ser sobreposto exportando a variável de
ambiente correspondente (por exemplo `DB_DATABASE`).

Com a configuração por omissão (`phpunit.xml`) estes testes são marcados como *skipped*,
porque a base de dados de testes não tem o esquema do marketplace.
