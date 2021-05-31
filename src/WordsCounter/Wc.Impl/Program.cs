using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Wc.Impl
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");

            var db = new WordsCounterDbContext();
            db.Database.ExecuteSqlRaw(@"TRUNCATE TABLE public.""DocumentSource""");
            var doc = File.ReadAllText(@"sample.txt").ToList();

            var pagesize = 256;

            for (int i = 0; i < doc.Count; i += pagesize)
            {
                
                db.DocumentSource.Add(new DocumentSource
                {
                    DocumentUuid = 3,
                    Content = new string(doc.GetRange(i, Math.Min(pagesize, doc.Count - i)).ToArray())
                });
            }

            db.SaveChanges();

            db.Dispose();
        }

        public static List<List<float[]>> SplitList(List<float[]> locations, int nSize = 30)
        {
            var list = new List<List<float[]>>();

            for (int i = 0; i < locations.Count; i += nSize)
            {
                list.Add(locations.GetRange(i, Math.Min(nSize, locations.Count - i)));
            }

            return list;
        }
    }

    public class WordsCounterDbContext : DbContext
    {
        public DbSet<DocumentSource> DocumentSource { get; set; }
//        public DbSet<DocumentWords> DocumentWords { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseNpgsql("Host=127.0.0.1;Port=9922;Database=dev_kit_db;Username=dev_kit_user;Password=password");

            
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasDefaultSchema("public");

            modelBuilder.Entity<DocumentSource>();//.Property(p => p.Vector);
                //.HasComputedColumnSql(@"tsvector_to_array(to_tsvector('english_hunspell',Content))", true);
        }
    }

    public class DocumentSource
    {
        public int Id { get; set; }
        public int DocumentUuid { get; set; }
        public string Content { get; set; }
        public string[] Vector { get; set; }
    }

    public class DocumentWords
    {
        public int Id { get; set; }
        public int  DocumentUuid { get; set; }
        public string Word { get; set; }
        public int Count { get; set; }
    }
}
