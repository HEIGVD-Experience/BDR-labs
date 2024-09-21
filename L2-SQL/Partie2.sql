CREATE OR REPLACE FUNCTION controleNomLit() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM Equipement 
      WHERE id = NEW.idEquipement AND lower(nom) LIKE '%lit%'
    ) THEN
      RAISE EXCEPTION 'Le nom doit contenir le mot lit';
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER CI_LIT BEFORE INSERT OR UPDATE ON Lit
FOR EACH ROW WHEN (NEW.idEquipement IS NOT NULL)
EXECUTE FUNCTION controleNomLit();