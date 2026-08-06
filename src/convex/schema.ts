import { authTables } from "@convex-dev/auth/server";
import { defineSchema, defineTable } from "convex/server";
import { Infer, v } from "convex/values";

export const ROLES = {
  ADMIN: "admin",
  USER: "user",
  MEMBER: "member",
} as const;

export const roleValidator = v.union(
  v.literal(ROLES.ADMIN),
  v.literal(ROLES.USER),
  v.literal(ROLES.MEMBER),
);
export type Role = Infer<typeof roleValidator>;

const schema = defineSchema(
  {
    ...authTables,

    users: defineTable({
      name: v.optional(v.string()),
      image: v.optional(v.string()),
      email: v.optional(v.string()),
      emailVerificationTime: v.optional(v.number()),
      isAnonymous: v.optional(v.boolean()),
      role: v.optional(roleValidator),
    }).index("email", ["email"]),

    trips: defineTable({
      userId: v.id("users"),
      title: v.string(),
      destination: v.string(),
      startDate: v.optional(v.string()),
      endDate: v.optional(v.string()),
      purpose: v.optional(v.string()),
      status: v.union(
        v.literal("planning"),
        v.literal("packing"),
        v.literal("ready"),
        v.literal("archived"),
      ),
      cover: v.optional(v.string()),
      createdAt: v.number(),
      updatedAt: v.number(),
    })
      .index("by_user", ["userId"])
      .index("by_user_updated", ["userId", "updatedAt"]),

    packingItems: defineTable({
      userId: v.id("users"),
      tripId: v.id("trips"),
      name: v.string(),
      category: v.string(),
      quantity: v.number(),
      packed: v.boolean(),
      essential: v.boolean(),
      notes: v.optional(v.string()),
      createdAt: v.number(),
    })
      .index("by_trip", ["tripId"])
      .index("by_user", ["userId"]),

    templates: defineTable({
      userId: v.id("users"),
      name: v.string(),
      description: v.optional(v.string()),
      tag: v.optional(v.string()),
      createdAt: v.number(),
    }).index("by_user", ["userId"]),

    templateItems: defineTable({
      templateId: v.id("templates"),
      name: v.string(),
      category: v.string(),
      quantity: v.number(),
      essential: v.boolean(),
    }).index("by_template", ["templateId"]),

    outfits: defineTable({
      userId: v.id("users"),
      tripId: v.id("trips"),
      name: v.string(),
      dayLabel: v.optional(v.string()),
      itemIds: v.array(v.id("packingItems")),
      note: v.optional(v.string()),
      createdAt: v.number(),
    })
      .index("by_trip", ["tripId"])
      .index("by_user", ["userId"]),
  },
  { schemaValidation: false },
);

export default schema;
