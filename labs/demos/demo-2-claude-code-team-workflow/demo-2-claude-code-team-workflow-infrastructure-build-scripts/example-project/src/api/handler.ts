// src/api/handler.ts
//
// Canonical shape of an HTTP handler in the Acme Commerce API.  This
// file is what `.claude/rules/api-rules.md` is scoped to — open it in
// Claude Code and you should see the API rules cited.  Open a file
// outside `src/api/**/*.ts` and the same rules should NOT be cited.
//
// The file is deliberately small and well-behaved; the point is the
// loading behaviour of the rule, not the sophistication of the code.

import { z } from "zod";

import { requireAuth } from "../lib/auth";
import { logger } from "../lib/logger";
import { AppError, TransientError } from "../lib/errors";
import type { AppRequest, AppResponse } from "../lib/http";

// Parse and validate every inbound payload with Zod.  Never read
// `req.body` fields directly — that path is blocked by api-rules.md.
const CreateOrderBody = z.object({
  sku: z.string().min(1),
  quantity: z.number().int().positive(),
  customerId: z.string().uuid(),
});

type CreateOrderBody = z.infer<typeof CreateOrderBody>;

/**
 * Create a new order for the authenticated customer.
 *
 * @param req - Authenticated Acme request.
 * @param res - Acme response wrapper; do not call `res.send` directly.
 * @returns   - Resolves after the response has been written.
 */
export async function createOrderHandler(
  req: AppRequest,
  res: AppResponse,
): Promise<void> {
  // Authn is always first.  If the session is missing, requireAuth
  // throws and the middleware returns 401.
  requireAuth(req);

  // Log the SHAPE of the request, never the values — PII rule.
  logger.info("createOrder entry", {
    bodyKeys: Object.keys(req.body ?? {}).length,
  });

  let body: CreateOrderBody;
  try {
    body = CreateOrderBody.parse(req.body);
  } catch (cause) {
    // Validation failures are not retryable.
    throw new AppError("invalid order payload", { cause, status: 400 });
  }

  try {
    const order = await placeOrder(body);
    res.status(201).json({ orderId: order.id });
  } catch (cause) {
    if (isRetryableDownstream(cause)) {
      // Throwing TransientError lets the retry middleware kick in.
      throw new TransientError("order service unavailable", { cause });
    }
    logger.warn("createOrder failed", { reason: String(cause) });
    throw new AppError("could not place order", { cause, status: 502 });
  }
}

// --- helpers ---------------------------------------------------------

async function placeOrder(body: CreateOrderBody): Promise<{ id: string }> {
  // In a real repo this would call the order service.  For this demo
  // we return a deterministic stub.
  return { id: `order_${body.sku}_${body.quantity}` };
}

function isRetryableDownstream(err: unknown): boolean {
  // Network blips from the order service are retryable; everything
  // else (4xx, contract mismatches) is not.
  if (!err || typeof err !== "object") return false;
  const code = (err as { code?: string }).code;
  return code === "ECONNRESET" || code === "ETIMEDOUT";
}
