using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

namespace Wc.Impl.Migrations
{
    public partial class Initial : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "public");

            migrationBuilder.CreateTable(
                name: "DocumentSource",
                schema: "public",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    DocumentUuid = table.Column<int>(type: "integer", nullable: false),
                    Content = table.Column<string>(type: "text", nullable: true),
                    Vector = table.Column<string[]>(type: "text[]", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DocumentSource", x => x.Id);
                });

            migrationBuilder.Sql(@"
                                        CREATE OR REPLACE FUNCTION UpdateDocumentSourceVector() RETURNS TRIGGER AS 
                                        $DocumentSourceUpdatedTrololo$
                                        BEGIN
	                                        NEW.""Vector"" := tsvector_to_array(to_tsvector('english_hunspell',NEW.""Content""));

                                            RETURN NEW;
                                                    END;
                                        $DocumentSourceUpdatedTrololo$ LANGUAGE plpgsql;

                                        create trigger DocumentSourceUpdated
                                        BEFORE INSERT OR UPDATE ON public.""DocumentSource"" FOR each ROW 
                                        EXECUTE FUNCTION UpdateDocumentSourceVector();

            ");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DocumentSource",
                schema: "public");

            migrationBuilder.Sql(@"
                                    drop trigger DocumentSourceUpdated on public.""DocumentSource"";
                                    drop function UpdateDocumentSourceVector;
            ");
        }
    }
}
