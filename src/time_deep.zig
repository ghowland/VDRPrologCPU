const std = @import("std");

pub const DeepTime = u64;

// Millisecond-resolution timestamp.
pub const TICKS_PER_SECOND: u64 = 1_000;
pub const SECONDS_PER_DAY: u64 = 86_400;
pub const SECONDS_PER_YEAR: u64 = 31_556_952; // 365.2425 days
pub const TICKS_PER_YEAR: u64 = SECONDS_PER_YEAR * TICKS_PER_SECOND;

pub const MAX_DEEP_TIME: DeepTime = std.math.maxInt(u64);

// Approximate total span of u64 milliseconds in years.
pub const TOTAL_YEARS_APPROX: u64 = 584_554_531;

// Chosen anchor: 100 million years before the CE boundary.
// This leaves plenty of future range at millisecond precision.
pub const ANCHOR_YEARS_BEFORE_CE: u64 = 100_000_000;
pub const ANCHOR_TICKS: DeepTime = ANCHOR_YEARS_BEFORE_CE * TICKS_PER_YEAR;

// Approximate years remaining into the future after that anchor.
pub const REMAINING_YEARS_APPROX: u64 =
    TOTAL_YEARS_APPROX - ANCHOR_YEARS_BEFORE_CE;

// Unix epoch in this custom scale, approximately.
// For exact interop, define the anchor as a precise instant and compute the
// exact offset once.
pub const UNIX_EPOCH_IN_DEEP_TIME: DeepTime = ANCHOR_TICKS;

// Rough interesting point: Big Bang estimate does NOT fit with millisecond
// resolution and this anchor strategy, because 13.8B years exceeds total span.

pub fn fromUnixMillis(unix_millis: i64) ?DeepTime {
    if (unix_millis < 0) return null;
    const ms: u64 = @intCast(unix_millis);
    return std.math.add(u64, ANCHOR_TICKS, ms) catch return null;
}

pub fn toUnixMillis(value: DeepTime) ?u64 {
    if (value < ANCHOR_TICKS) return null;
    return value - ANCHOR_TICKS;
}

pub fn fromUnixSeconds(unix_seconds: i64) ?DeepTime {
    if (unix_seconds < 0) return null;
    const s: u64 = @intCast(unix_seconds);
    const ms = std.math.mul(u64, s, TICKS_PER_SECOND) catch return null;
    return std.math.add(u64, ANCHOR_TICKS, ms) catch return null;
}

pub fn toUnixSeconds(value: DeepTime) ?u64 {
    if (value < ANCHOR_TICKS) return null;
    return (value - ANCHOR_TICKS) / TICKS_PER_SECOND;
}
