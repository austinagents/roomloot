import { NextResponse } from "next/server";

export function json(data: unknown, status = 200) {
  return NextResponse.json(data, { status });
}

export function badRequest(error: string) {
  return json({ success: false, error }, 400);
}

export function serverError(error: string) {
  return json({ success: false, error }, 500);
}

export function mapSupabaseError(error: { message?: string } | null) {
  return error?.message ?? "Unexpected database error.";
}

