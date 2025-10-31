export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      businesses: {
        Row: {
          id: string
          name: string
          slug: string
          logo_url: string | null
          custom_domain: string | null
          theme: Json
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          slug: string
          logo_url?: string | null
          custom_domain?: string | null
          theme?: Json
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          slug?: string
          logo_url?: string | null
          custom_domain?: string | null
          theme?: Json
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      users: {
        Row: {
          id: string
          email: string
          full_name: string | null
          role: 'super_admin' | 'business_admin'
          business_id: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          email: string
          full_name?: string | null
          role: 'super_admin' | 'business_admin'
          business_id?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          full_name?: string | null
          role?: 'super_admin' | 'business_admin'
          business_id?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      forms: {
        Row: {
          id: string
          business_id: string
          title: string
          description: string | null
          slug: string
          schema: Json
          settings: Json
          conditional_logic: Json
          is_active: boolean
          is_published: boolean
          created_by: string | null
          created_at: string
          updated_at: string
          published_at: string | null
        }
        Insert: {
          id?: string
          business_id: string
          title: string
          description?: string | null
          slug: string
          schema?: Json
          settings?: Json
          conditional_logic?: Json
          is_active?: boolean
          is_published?: boolean
          created_by?: string | null
          created_at?: string
          updated_at?: string
          published_at?: string | null
        }
        Update: {
          id?: string
          business_id?: string
          title?: string
          description?: string | null
          slug?: string
          schema?: Json
          settings?: Json
          conditional_logic?: Json
          is_active?: boolean
          is_published?: boolean
          created_by?: string | null
          created_at?: string
          updated_at?: string
          published_at?: string | null
        }
      }
      submissions: {
        Row: {
          id: string
          form_id: string
          business_id: string
          data: Json
          metadata: Json
          signature_url: string | null
          is_duplicate: boolean
          duplicate_check_key: string | null
          status: 'draft' | 'completed' | 'archived'
          submitted_at: string
          created_at: string
        }
        Insert: {
          id?: string
          form_id: string
          business_id: string
          data: Json
          metadata?: Json
          signature_url?: string | null
          is_duplicate?: boolean
          duplicate_check_key?: string | null
          status?: 'draft' | 'completed' | 'archived'
          submitted_at?: string
          created_at?: string
        }
        Update: {
          id?: string
          form_id?: string
          business_id?: string
          data?: Json
          metadata?: Json
          signature_url?: string | null
          is_duplicate?: boolean
          duplicate_check_key?: string | null
          status?: 'draft' | 'completed' | 'archived'
          submitted_at?: string
          created_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
