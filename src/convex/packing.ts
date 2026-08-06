import { getAuthUserId } from "@convex-dev/auth/server";
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

async function requireUser(ctx: any) {
  const userId = await getAuthUserId(ctx);
  if (!userId) throw new Error("Not authenticated");
  return userId as any;
}

// ── Trips ──
export const listTrips = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return [];
    return await ctx.db
      .query("trips")
      .withIndex("by_user_updated", (q) => q.eq("userId", userId))
      .order("desc")
      .collect();
  },
});

export const getTrip = query({
  args: { tripId: v.id("trips") },
  handler: async (ctx, { tripId }) => {
    const trip = await ctx.db.get(tripId);
    if (!trip) return null;
    return trip;
  },
});

export const createTrip = mutation({
  args: {
    title: v.string(),
    destination: v.string(),
    startDate: v.optional(v.string()),
    endDate: v.optional(v.string()),
    purpose: v.optional(v.string()),
    cover: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx);
    const now = Date.now();
    return await ctx.db.insert("trips", {
      userId,
      title: args.title.trim(),
      destination: args.destination.trim(),
      startDate: args.startDate,
      endDate: args.endDate,
      purpose: args.purpose,
      status: "planning",
      cover: args.cover,
      createdAt: now,
      updatedAt: now,
    });
  },
});

export const updateTripStatus = mutation({
  args: {
    tripId: v.id("trips"),
    status: v.union(
      v.literal("planning"),
      v.literal("packing"),
      v.literal("ready"),
      v.literal("archived"),
    ),
  },
  handler: async (ctx, { tripId, status }) => {
    const userId = await requireUser(ctx);
    const trip = await ctx.db.get(tripId);
    if (!trip || trip.userId !== userId) throw new Error("Trip not found");
    await ctx.db.patch(tripId, { status, updatedAt: Date.now() });
  },
});

export const deleteTrip = mutation({
  args: { tripId: v.id("trips") },
  handler: async (ctx, { tripId }) => {
    const userId = await requireUser(ctx);
    const trip = await ctx.db.get(tripId);
    if (!trip || trip.userId !== userId) throw new Error("Trip not found");
    const items = await ctx.db
      .query("packingItems")
      .withIndex("by_trip", (q) => q.eq("tripId", tripId))
      .collect();
    for (const it of items) await ctx.db.delete(it._id);
    const outfits = await ctx.db
      .query("outfits")
      .withIndex("by_trip", (q) => q.eq("tripId", tripId))
      .collect();
    for (const o of outfits) await ctx.db.delete(o._id);
    await ctx.db.delete(tripId);
  },
});

export const duplicateTrip = mutation({
  args: { tripId: v.id("trips") },
  handler: async (ctx, { tripId }) => {
    const userId = await requireUser(ctx);
    const trip = await ctx.db.get(tripId);
    if (!trip || trip.userId !== userId) throw new Error("Trip not found");
    const now = Date.now();
    const newId = await ctx.db.insert("trips", {
      userId,
      title: trip.title + " (copy)",
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      purpose: trip.purpose,
      status: "planning",
      cover: trip.cover,
      createdAt: now,
      updatedAt: now,
    });
    const items = await ctx.db
      .query("packingItems")
      .withIndex("by_trip", (q) => q.eq("tripId", tripId))
      .collect();
    for (const it of items) {
      await ctx.db.insert("packingItems", {
        userId,
        tripId: newId,
        name: it.name,
        category: it.category,
        quantity: it.quantity,
        packed: false,
        essential: it.essential,
        notes: it.notes,
        createdAt: now,
      });
    }
    return newId;
  },
});

// ── Packing Items ──
export const listItems = query({
  args: { tripId: v.id("trips") },
  handler: async (ctx, { tripId }) => {
    return await ctx.db
      .query("packingItems")
      .withIndex("by_trip", (q) => q.eq("tripId", tripId))
      .collect();
  },
});

export const addItem = mutation({
  args: {
    tripId: v.id("trips"),
    name: v.string(),
    category: v.string(),
    quantity: v.optional(v.number()),
    essential: v.optional(v.boolean()),
    notes: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx);
    const trip = await ctx.db.get(args.tripId);
    if (!trip || trip.userId !== userId) throw new Error("Trip not found");
    await ctx.db.patch(args.tripId, { updatedAt: Date.now() });
    return await ctx.db.insert("packingItems", {
      userId,
      tripId: args.tripId,
      name: args.name.trim(),
      category: args.category || "General",
      quantity: args.quantity ?? 1,
      packed: false,
      essential: args.essential ?? false,
      notes: args.notes,
      createdAt: Date.now(),
    });
  },
});

export const togglePacked = mutation({
  args: { itemId: v.id("packingItems") },
  handler: async (ctx, { itemId }) => {
    const userId = await requireUser(ctx);
    const item = await ctx.db.get(itemId);
    if (!item || item.userId !== userId) throw new Error("Item not found");
    await ctx.db.patch(itemId, { packed: !item.packed });
  },
});

export const updateItem = mutation({
  args: {
    itemId: v.id("packingItems"),
    name: v.optional(v.string()),
    category: v.optional(v.string()),
    quantity: v.optional(v.number()),
    essential: v.optional(v.boolean()),
    notes: v.optional(v.string()),
  },
  handler: async (ctx, { itemId, ...rest }) => {
    const userId = await requireUser(ctx);
    const item = await ctx.db.get(itemId);
    if (!item || item.userId !== userId) throw new Error("Item not found");
    const patch: any = {};
    if (rest.name !== undefined) patch.name = rest.name.trim();
    if (rest.category !== undefined) patch.category = rest.category;
    if (rest.quantity !== undefined) patch.quantity = rest.quantity;
    if (rest.essential !== undefined) patch.essential = rest.essential;
    if (rest.notes !== undefined) patch.notes = rest.notes;
    await ctx.db.patch(itemId, patch);
  },
});

export const deleteItem = mutation({
  args: { itemId: v.id("packingItems") },
  handler: async (ctx, { itemId }) => {
    const userId = await requireUser(ctx);
    const item = await ctx.db.get(itemId);
    if (!item || item.userId !== userId) throw new Error("Item not found");
    await ctx.db.delete(itemId);
  },
});

// ── Templates ──
export const listTemplates = query({
  args: {},
  handler: async (ctx) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) return [];
    return await ctx.db
      .query("templates")
      .withIndex("by_user", (q) => q.eq("userId", userId))
      .collect();
  },
});

export const createTemplate = mutation({
  args: {
    name: v.string(),
    description: v.optional(v.string()),
    tag: v.optional(v.string()),
    items: v.array(
      v.object({
        name: v.string(),
        category: v.string(),
        quantity: v.number(),
        essential: v.boolean(),
      }),
    ),
  },
  handler: async (ctx, { name, description, tag, items }) => {
    const userId = await requireUser(ctx);
    const id = await ctx.db.insert("templates", {
      userId,
      name: name.trim(),
      description,
      tag,
      createdAt: Date.now(),
    });
    for (const it of items) {
      await ctx.db.insert("templateItems", {
        templateId: id,
        name: it.name,
        category: it.category,
        quantity: it.quantity,
        essential: it.essential,
      });
    }
    return id;
  },
});

export const getTemplateItems = query({
  args: { templateId: v.id("templates") },
  handler: async (ctx, { templateId }) => {
    return await ctx.db
      .query("templateItems")
      .withIndex("by_template", (q) => q.eq("templateId", templateId))
      .collect();
  },
});

export const applyTemplate = mutation({
  args: { templateId: v.id("templates"), tripId: v.id("trips") },
  handler: async (ctx, { templateId, tripId }) => {
    const userId = await requireUser(ctx);
    const trip = await ctx.db.get(tripId);
    if (!trip || trip.userId !== userId) throw new Error("Trip not found");
    const tItems = await ctx.db
      .query("templateItems")
      .withIndex("by_template", (q) => q.eq("templateId", templateId))
      .collect();
    const now = Date.now();
    for (const it of tItems) {
      await ctx.db.insert("packingItems", {
        userId,
        tripId,
        name: it.name,
        category: it.category,
        quantity: it.quantity,
        packed: false,
        essential: it.essential,
        createdAt: now,
      });
    }
    await ctx.db.patch(tripId, { updatedAt: now });
  },
});

export const deleteTemplate = mutation({
  args: { templateId: v.id("templates") },
  handler: async (ctx, { templateId }) => {
    const userId = await requireUser(ctx);
    const t = await ctx.db.get(templateId);
    if (!t || t.userId !== userId) throw new Error("Not found");
    const items = await ctx.db
      .query("templateItems")
      .withIndex("by_template", (q) => q.eq("templateId", templateId))
      .collect();
    for (const it of items) await ctx.db.delete(it._id);
    await ctx.db.delete(templateId);
  },
});

// ── Outfits ──
export const listOutfits = query({
  args: { tripId: v.id("trips") },
  handler: async (ctx, { tripId }) => {
    return await ctx.db
      .query("outfits")
      .withIndex("by_trip", (q) => q.eq("tripId", tripId))
      .collect();
  },
});

export const createOutfit = mutation({
  args: {
    tripId: v.id("trips"),
    name: v.string(),
    dayLabel: v.optional(v.string()),
    itemIds: v.array(v.id("packingItems")),
    note: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const userId = await requireUser(ctx);
    return await ctx.db.insert("outfits", {
      userId,
      tripId: args.tripId,
      name: args.name.trim(),
      dayLabel: args.dayLabel,
      itemIds: args.itemIds,
      note: args.note,
      createdAt: Date.now(),
    });
  },
});

export const deleteOutfit = mutation({
  args: { outfitId: v.id("outfits") },
  handler: async (ctx, { outfitId }) => {
    const userId = await requireUser(ctx);
    const o = await ctx.db.get(outfitId);
    if (!o || o.userId !== userId) throw new Error("Not found");
    await ctx.db.delete(outfitId);
  },
});
